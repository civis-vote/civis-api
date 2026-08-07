class Consultation < ApplicationRecord
  SKIP_AUTH_STAGING_ID = 0
  SKIP_AUTH_PRODUCTION_ID = 0

  attr_accessor :respondent_emails

  enum :status, {
    submitted: 0,
    published: 1,
    rejected: 2,
    expired: 3
  }
  enum :review_type, {
    consultation: 0,
    policy: 1
  }
  enum :visibility, {
    public_consultation: 0,
    private_consultation: 1
  }
  enum :question_flow, {
    question_list: 0,
    single_question: 1
  }

  acts_as_paranoid
  has_paper_trail

  include Paginator
  include Scorable::Consultation
  include CmAdmin::Consultation

  has_rich_text :summary
  has_rich_text :response_submission_message

  has_rich_text :english_summary
  has_rich_text :hindi_summary
  has_rich_text :odia_summary
  has_rich_text :marathi_summary
  has_rich_text :kannada_summary
  has_rich_text :ai_summary

  has_one_attached :consultation_logo
  has_one_attached :consultation_pdf

  validate :pdf_content_type
  validate :pdf_file_size

  belongs_to :department
  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User", optional: true
  belongs_to :organisation, optional: true
  belongs_to :theme, optional: true

  has_many :responses, class_name: "ConsultationResponse"
  has_many :shared_responses, -> { shared }, class_name: "ConsultationResponse"
  has_many :anonymous_responses, -> { anonymous }, class_name: "ConsultationResponse"
  has_many :response_rounds
  has_many :respondents, through: :response_rounds
  has_many :clauses, dependent: :destroy
  has_one :response_summary, dependent: :destroy
  has_many :constant_maps, as: :mappable, dependent: :destroy
  has_many :segments, -> { segment }, through: :constant_maps, source: :constant
  has_many :area_of_impacts, -> { area_of_impact }, through: :constant_maps, source: :constant

  validates_presence_of :response_deadline, :question_flow

  before_validation :set_created_by, :set_default_value_for_organisation_consultation, on: :create
  after_commit :set_consultation_expiry_job, if: :saved_change_to_response_deadline?
  after_commit :create_response_round, on: :create
  after_commit :notify_admins, on: :create

  delegate :full_name, to: :created_by, prefix: true, allow_nil: true
  delegate :name, to: :department, prefix: true, allow_nil: true
  delegate :count, to: :responses, prefix: true, allow_nil: true
  delegate :name, to: :theme, prefix: true, allow_nil: true

  scope :status_filter, lambda { |status|
    return all unless status.present?

    where(status: status)
  }

  scope :department_filter, lambda { |department_id|
    return all unless department_id.present?

    where(department_id: department_id)
  }

  scope :theme_filter, lambda { |theme_id|
    return all unless theme_id.present?

    where(theme_id: theme_id)
  }

  scope :area_of_impact_filter, lambda { |area_of_impact_ids|
    return all unless area_of_impact_ids.present?

    joins(:constant_maps).where(constant_maps: { constant_id: area_of_impact_ids }).distinct
  }

  scope :featured_filter, lambda { |featured|
    return all unless featured.present?

    where(is_featured: featured)
  }

  scope :search_query, lambda { |query = nil|
    return nil unless query

    where("title ILIKE (?)", "%#{query}%")
  }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return nil if sort.blank?

    order("#{sort} #{sort_direction}")
  }

  scope :visibility_filter, lambda { |visibility|
    return all unless visibility.present?

    where(visibility: visibility)
  }

  scope :consultation_status, lambda { |status|
    return all unless status.present?

    where(status: status)
  }

  scope :organisation_only, -> { where(organisation_id: Current.user&.organisation_id) }

  def notify_admins
    self.response_token = SecureRandom.uuid unless response_token
    save!
    NotifyNewConsultationEmailToAdminJob.perform_later(self)
  end

  def segment_names
    segments.map(&:name).join(", ")
  end

  def area_of_impact_names
    area_of_impacts.map(&:name).join(", ")
  end

  def publish
    self.status = :published
    self.published_at = DateTime.now unless published_at.present?
    save!
    return unless private_consultation?

    respondents = Respondent.where(response_round_id: response_round_ids)
    respondents.each do |respondent|
      url = Respondent.respondent_invite_url(self, respondent.user)
      InviteRespondentJob.perform_later(self, respondent.user, url)
    end
  end

  def reject
    update(status: :rejected)
  end

  def expire
    expired!
    return unless responses.acceptable.size.positive?

    feedback_report_email(consultation_feedback_email, officer_name, officer_designation) if consultation_feedback_email
    if consultation?
      if department.primary_contact.present?
        feedback_report_email(department.primary_contact.email, department.primary_contact.name,
                              department.primary_contact.designation)
      end
      if department.secondary_contact.present?
        feedback_report_email(department.secondary_contact.email, department.secondary_contact.name,
                              department.secondary_contact.designation)
      end
    end
    UserUpVoteResponsesEmailJob.perform_later(self)
    UseResponseAsTemplateEmailJob.perform_later(self)
    compute_response_summary
  end

  def compute_response_summary
    acceptable = responses.acceptable_responses
    response_round = response_rounds.order(:created_at).last
    questions = response_round&.questions&.main_questions&.order(:position) || []

    question_summaries = questions.map do |question|
      build_question_summary_attributes(question, acceptable)
    end

    response_summary&.destroy
    create_response_summary!(total_responses: acceptable.size, question_summaries_attributes: question_summaries)
  end

  def build_question_summary_attributes(question, all_responses)
    answered = all_responses.select { |r| r.answers&.any? { |a| a['question_id'].to_i == question.id } }

    attributes = {
      question_id: question.id,
      question_text: question.question_text,
      question_type: Question.question_types[question.question_type],
      is_optional: question.is_optional,
      position: question.position,
      total_responses: answered.size
    }

    if question.display_options?
      attributes.merge!(build_option_breakdown_attributes(question, answered))
    elsif question.long_text?
      attributes[:text_response_count] = answered.size
    end

    if question.accept_voice_message
      attributes[:voice_response_count] = answered.count do |r|
        r.voice_responses&.any? { |v| v['question_id'].to_i == question.id }
      end
    end

    attributes
  end

  def build_option_breakdown_attributes(question, responses)
    option_counts = Hash.new(0)
    other_count = 0

    responses.each do |response|
      answer_data = response.answers&.find { |a| a['question_id'].to_i == question.id }
      next unless answer_data

      other_count += 1 if answer_data['is_other']

      selected_ids = Array(answer_data['answer'])
      selected_ids.each do |sid|
        option_counts[sid.to_i] += 1 if sid.is_a?(Integer) || sid.to_s.match?(/\A\d+\z/)
      end
    end

    total = responses.size.to_f
    breakdown = question.sub_questions.map do |option|
      count = option_counts[option.id]
      {
        option_id: option.id,
        option_text: option.question_text,
        selection_count: count,
        percentage: total.positive? ? ((count / total) * 100).round(2) : 0.0
      }
    end

    { option_breakdowns_attributes: breakdown, other_option_count: other_count }
  end

  def responded_on(user = Current.user)
    user_response = responses.find_by(user: user)
    return nil if user_response.nil?

    user_response.created_at
  end

  def satisfaction_rating_distribution
    responses.group(:satisfaction_rating).count(:satisfaction_rating)
  end

  def featured
    update(is_featured: true)
  end

  def unfeatured
    update(is_featured: false)
  end

  def update_reading_time
    contents = english_summary.to_s.gsub(/<[^>]*>/, ' ')
    total_word_count = contents.split.size
    time = total_word_count.to_f / 200
    time_with_divmod = time.divmod 1
    array = [time_with_divmod[0].to_i, time_with_divmod[1].round(2) * 0.60]
    total_reading_time = if array[1] > 0.30
                           array[0] + 1
                         else
                           array[0]
                         end
    self.reading_time = total_reading_time
    save
  end

  def days_left
    (response_deadline.to_date - Date.current).to_i if response_deadline && published_at
  end

  def feedback_url
    feedback_url = URI::HTTP.build(Rails.application.config.client_url.merge!({ path: "/consultations/#{id}/read", query: nil }))
    feedback_url.to_s
  end

  def english_summary_rich_text
    convert_to_rich_text(english_summary.to_s)
  end

  def hindi_summary_rich_text
    convert_to_rich_text(hindi_summary.to_s)
  end

  def odia_summary_rich_text
    convert_to_rich_text(odia_summary.to_s)
  end

  def marathi_summary_rich_text
    convert_to_rich_text(marathi_summary.to_s)
  end

  def kannada_summary_rich_text
    convert_to_rich_text(kannada_summary.to_s)
  end

  def response_url
    response_url = URI::HTTP.build(Rails.application.config.client_url.merge!({ path: "/consultations/#{id}/summary",
                                                                                query: "response_token=#{response_token}" }))
    response_url.to_s
  end

  def review_url
    response_url = URI::HTTP.build(Rails.application.config.host_url.merge!({ path: "/cm_admin/consultations/#{id}", query: nil }))
    response_url.to_s
  end

  def create_response_round
    response_rounds.create
  end

  def picture_url
    return unless consultation_logo.attached?

    consultation_logo
  end

  def extend_deadline(deadline_date)
    self.response_deadline = deadline_date
    publish
  end

  def is_user_from_same_organisation?
    true if organisation_id == Current.user.organisation_id
  end

  def english_summary_text
    return summary.to_plain_text if summary.to_plain_text.present?

    english_summary.to_plain_text if english_summary.present?
  end

  def hindi_summary_text
    hindi_summary.to_plain_text
  end

  def odia_summary_text
    odia_summary.to_plain_text
  end

  def marathi_summary_text
    marathi_summary.to_plain_text
  end

  def kannada_summary_text
    kannada_summary.to_plain_text
  end

  def set_consultation_expiry_job
    ConsultationExpiryJob.set(wait_until: response_deadline).perform_later(self)
    publish if public_consultation? && expired? && response_deadline > Time.current
  end

  def can_extend_deadline_or_create_response_round?
    private_consultation? && expired?
  end

  def duplicate
    fields = attributes.except('id', 'created_at', 'updated_at', 'status', 'title', 'response_token', 'created_by_id')
    consultation = ::Consultation.new(fields)
    consultation.title = "Copy of #{title}"
    consultation.created_by_id = Current.user&.id
    consultation.status = :submitted
    consultation.summary = summary
    consultation.response_submission_message = response_submission_message
    consultation.english_summary = english_summary
    consultation.hindi_summary = hindi_summary
    consultation.odia_summary = odia_summary
    consultation.marathi_summary = marathi_summary
    consultation.kannada_summary = kannada_summary
    consultation.save!
    consultation.consultation_logo.attach(consultation_logo.blob)

    consultation.response_rounds.destroy_all
    response_rounds.each do |response_round|
      new_response_round = consultation.response_rounds.create!
      response_round.questions.each do |question|
        new_question = new_response_round.questions.create!(question.attributes.except('id', 'created_at', 'updated_at'))
        question.sub_questions.each do |sub_question|
          new_question.sub_questions.create!(sub_question.attributes.except('id', 'created_at', 'updated_at'))
        end
      end
    end
  end

  def extract_clauses
    ExtractClausesJob.perform_later(id)
  end

  def summarise_pdf
    ConsultationSummaryJob.perform_later(self)
  end

  private

  def pdf_content_type
    return unless consultation_pdf.attached?

    errors.add(:consultation_pdf, 'Only PDF files are supported') unless consultation_pdf.blob.content_type == 'application/pdf'
  end

  def pdf_file_size
    return unless consultation_pdf.attached?

    errors.add(:consultation_pdf, 'PDF must be less than 50MB') if consultation_pdf.blob.byte_size > 50.megabytes
  end

  def set_default_value_for_organisation_consultation
    return unless Current.user&.role?('organisation_employee')

    self.organisation_id = Current.user&.organisation_id
    self.visibility = :private_consultation
  end

  def set_created_by
    self.created_by = Current.user
  end

  def feedback_report_email(email, officer_name, officer_designation)
    ConsultationFeedbackReportEmailJob.perform_later(email, self, officer_name, officer_designation)
  end

  def convert_to_rich_text(text)
    match = '<action-text-attachment content="<div style=&quot;width: 100%; height: 15px; display: flex; align-items: center; margin: 5px 0; padding: 5px; transition: background-color 0.2s ease-in-out;&quot;><div style=&quot;width: 100%; border: 1px solid #ececec;&quot;></div></div>">☒</action-text-attachment>'
    # regex to replace action-text-attachement with divider
    text.gsub!(match,
               '<div style="width: 100%; height: 15px; display: flex; align-items: center; margin: 5px 0; padding: 5px; transition: background-color 0.2s ease-in-out;"><div style="width: 100%; border: 1px solid #ececec;"></div></div>')
    # regex to replace action-text-attachement with image
    text.gsub!(%r{<action-text-attachment[^>]*>|</action-text-attachment>|<figure[^>]*>|</figure>}, '')
    # regex to replace youtube image link with iframe
    youtube_img_regex = %r{<img(?:\s+[\w-]+="[^"]*")*\s+src="https://img\.youtube\.com/vi/([\w-]+)/0\.jpg">}
    text.gsub(youtube_img_regex) do |_match|
      video_id = ::Regexp.last_match(1)
      "<iframe width=\"100%\" height=\"369\" src=\"https://www.youtube.com/embed/#{video_id}\" frameborder=\"0\"></iframe>"
    end
  end
end
