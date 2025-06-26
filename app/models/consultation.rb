class Consultation < ApplicationRecord
  SKIP_AUTH_STAGING_ID = 0
  SKIP_AUTH_PRODUCTION_ID = 0

  acts_as_paranoid
  include SpotlightSearch
  include Paginator
  include ImageResizer
  include Scorable::Consultation
  has_rich_text :summary
  has_rich_text :response_submission_message

  has_rich_text :english_summary
  has_rich_text :hindi_summary
  has_rich_text :odia_summary
  has_rich_text :marathi_summary

  has_one_attached :consultation_logo

  belongs_to :ministry
  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User", optional: true
  belongs_to :organisation, optional: true
  has_many :responses, class_name: "ConsultationResponse"
  has_many :shared_responses, -> { shared }, class_name: "ConsultationResponse"
  has_many :anonymous_responses, -> { anonymous }, class_name: "ConsultationResponse"
  has_many :response_rounds
  enum status: { submitted: 0, published: 1, rejected: 2, expired: 3 }
  enum review_type: { consultation: 0, policy: 1 }
  enum visibility: { public_consultation: 0, private_consultation: 1 }

  validates_presence_of :response_deadline

  after_commit :set_consultation_expiry_job, if: :saved_change_to_response_deadline?
  after_commit :create_response_round, on: :create
  after_commit :notify_admins, on: :create

  scope :status_filter, lambda { |status|
    return all unless status.present?
    where(status: status)
  }

  scope :ministry_filter, lambda { |ministry_id|
    return all unless ministry_id.present?
    where(ministry_id: ministry_id)
  }

  scope :category_filter, lambda { |category_id|
    return all unless category_id.present?
    joins(ministry: :category).
    where(categories: {id: category_id})
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

  def notify_admins
    self.response_token = SecureRandom.uuid unless self.response_token
    self.save!
    NotifyNewConsultationEmailToAdminJob.perform_later(self)
  end

  def publish
  	self.status = :published
  	self.published_at = DateTime.now unless self.published_at.present?
  	self.save!
    NotifyNewConsultationPolicyReviewEmailJob.perform_later(self) unless self.consultation?
    NotifyPublishedConsultationEmailJob.perform_later(self) if self.created_by.citizen?
    if self.private_consultation?
      respondents = Respondent.where(response_round_id: self.response_round_ids)
      respondents.each do |respondent|
        url = Respondent.respondent_invite_url(self, respondent.user)
        InviteRespondentJob.perform_later(self, respondent.user, url)
      end
    end
  end

  def reject
  	self.update(status: :rejected)
  end

  def expire
    expired!
    return unless responses.acceptable.size.positive?

    feedback_report_email(consultation_feedback_email, officer_name, officer_designation) if consultation_feedback_email
    if consultation?
      feedback_report_email(ministry.poc_email_primary, ministry.primary_officer_name, ministry.primary_officer_designation) if ministry.poc_email_primary
      feedback_report_email(ministry.poc_email_secondary, ministry.secondary_officer_name, ministry.secondary_officer_designation) if ministry.poc_email_secondary
    end
    UserUpVoteResponsesEmailJob.perform_later(self)
    UseResponseAsTemplateEmailJob.perform_later(self)
  end

  def responded_on(user = Current.user)
    user_response = self.responses.find_by(user: user)
    return nil if user_response.nil?
    return user_response.created_at
  end

  def satisfaction_rating_distribution
    self.responses.group(:satisfaction_rating).count(:satisfaction_rating)
  end

  def featured
    self.update(is_featured: true)
  end

  def unfeatured
    self.update(is_featured: false)
  end

  def update_reading_time
    contents = english_summary.to_s.gsub(/<[^>]*>/,' ')
    total_word_count = contents.split.size
    time = total_word_count.to_f / 200
    time_with_divmod = time.divmod 1
    array = [time_with_divmod[0].to_i, time_with_divmod[1].round(2) * 0.60 ]
    if array[1] > 0.30
      total_reading_time = array[0] + 1
    else
      total_reading_time = array[0]
    end
    self.reading_time = total_reading_time
    self.save
  end

  def days_left
    (response_deadline.to_date - Date.current).to_i if (response_deadline && published_at)
  end

  def feedback_url
    feedback_url = URI::HTTP.build(Rails.application.config.client_url.merge!({ path: "/consultations/" + "#{self.id}" +"/read", query: nil } ))
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

  def response_url
    response_url = URI::HTTP.build(Rails.application.config.client_url.merge!({ path: "/consultations/" + "#{self.id}" +"/summary", query: "response_token=#{self.response_token}" } ))
    response_url.to_s
  end

  def review_url
    response_url = URI::HTTP.build(Rails.application.config.client_url.merge!({ path: "/admin/consultations/" + "#{self.id}", query: nil } ))
    response_url.to_s
  end

  def create_response_round
    self.response_rounds.create()
  end

  def picture_url
    if consultation_logo.attached?
      consultation_logo
    else
      nil
    end
  end

  def extend_deadline(deadline_date)
    self.response_deadline = deadline_date
    self.publish
  end

  def is_user_from_same_organisation?
   return true if self.organisation_id == Current.user.organisation_id
  end

  def english_summary_text
    return summary.to_plain_text if summary.to_plain_text.present?

    english_summary.to_plain_text if english_summary.present?
  end

  def set_consultation_expiry_job
    ConsultationExpiryJob.set(wait_until: TZInfo::Timezone.get("Asia/Kolkata").local_to_utc(Time.parse(self.response_deadline.to_datetime.to_s))).perform_later(self)
  end

  private

  def feedback_report_email(email, officer_name, officer_designation)
    ConsultationFeedbackReportEmailJob.perform_later(email, self, officer_name, officer_designation)
  end

  def convert_to_rich_text(text)
    match = '<action-text-attachment content="<div style=&quot;width: 100%; height: 15px; display: flex; align-items: center; margin: 5px 0; padding: 5px; transition: background-color 0.2s ease-in-out;&quot;><div style=&quot;width: 100%; border: 1px solid #ececec;&quot;></div></div>">☒</action-text-attachment>'
    # regex to replace action-text-attachement with divider
    text.gsub!(match, '<div style="width: 100%; height: 15px; display: flex; align-items: center; margin: 5px 0; padding: 5px; transition: background-color 0.2s ease-in-out;"><div style="width: 100%; border: 1px solid #ececec;"></div></div>')
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
