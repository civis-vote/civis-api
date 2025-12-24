class ConsultationResponse < ApplicationRecord
  acts_as_paranoid
  has_paper_trail


  enum visibility: { shared: 0, anonymous: 1 }
  enum response_status: { acceptable: 0, under_review: 1, unacceptable: 2 }
  enum source: { platform: 0, off_platform: 1 }
  enum satisfaction_rating: %i[dissatisfied somewhat_dissatisfied somewhat_satisfied satisfied]
  enum response_language: {
    english: "English",
    hindi: "Hindi",
    marathi: "Marathi",
    odia: "Odia"
  }

  include Paginator
  include Scorable::ConsultationResponse
  include CmAdmin::ConsultationResponse

  has_rich_text :response_text

  has_many_attached :voice_messages

  belongs_to :user, optional: true
  belongs_to :consultation, counter_cache: true, optional: true
  validates_uniqueness_of :user_id, scope: :response_round_id, unless: proc { |_user| user_id.blank? }
  belongs_to :template, class_name: "ConsultationResponse", optional: true, counter_cache: :templates_count
  has_many :template_children, class_name: "ConsultationResponse", foreign_key: "template_id"
  has_many :up_votes, -> { up }, class_name: "ConsultationResponseVote"
  has_many :down_votes, -> { down }, class_name: "ConsultationResponseVote"
  has_many :votes, class_name: "ConsultationResponseVote"
  belongs_to :respondent, optional: true
  belongs_to :response_round
  belongs_to :organisation, optional: true

  before_commit :update_reading_time
  before_commit :validate_html_tags
  before_commit :validate_answers
  before_commit :validate_answers, on: :create
  after_commit :notify_admin_if_profane, on: :create
  before_commit :check_if_consultation_expired?, :set_subjective_objective_response_count, on: :create

  store_accessor :meta, :approved_by_id, :rejected_by_id, :approved_at, :rejected_at

  delegate :full_name, to: :user, prefix: true, allow_nil: true
  delegate :title, to: :consultation, prefix: true, allow_nil: true

  # scopes
  scope :consultation_filter, lambda { |consultation_id|
    return all unless consultation_id.present?

    where(consultation_id: consultation_id)
  }

  scope :sort_records, lambda { |sort = "created_at", sort_direction = "asc"|
    order("consultation_responses.#{sort} #{sort_direction}")
  }

  scope :published_consultation, lambda {
    joins(:consultation).where(consultations: { status: 'published' })
  }

  scope :response_filter, lambda { |response_status|
    return all unless response_status.present?

    where(response_status: response_status)
  }

  scope :department_filter, lambda { |department_ids|
    return all unless department_ids.present?

    joins(consultation: :department).where(departments: { id: department_ids })
  }

  scope :theme_filter, lambda { |theme_ids|
    return all unless theme_ids.present?

    joins(:consultation).where(consultations: { theme_id: theme_ids })
  }

  scope :organisation_only, -> { where(organisation_id: Current.user&.organisation_id) }

  def self.acceptable_responses
    where(response_status: 'acceptable')
  end

  def self.public_consultation_response_filter
    joins(:consultation).where(consultations: { visibility: 'public_consultation' })
  end

  def user_response
    response_text.to_plain_text
  end

  def refresh_consultation_response_up_vote_count
    update(up_vote_count: up_votes.size)
  end

  def refresh_consultation_response_down_vote_count
    update(down_vote_count: down_votes.size)
  end

  def voted_as(user = Current.user)
    user_vote = votes.find_by(user: user)
    return nil if user_vote.nil?

    user_vote
  end

  def submit_voice_responses(voice_responses)
    updated_response = []
    voice_responses&.each do |answer|
      question_id, file = answer[:question_id], answer[:file]
      voice_messages.attach(io: file, filename: file.original_filename)
      save!
      attachment = voice_messages.last
      updated_response << { question_id:, attachment_id: attachment.id }
    end
    update!(voice_responses: updated_response)
  end

  def update_reading_time
    return unless reading_time.blank? || response_text.saved_change_to_body?
    return unless response_text && shared?

    total_word_count = response_text.body.to_plain_text.scan(/\w+/).size
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

  def validate_html_tags
    return response_text.body.blank?
    return true if response_text.body.to_html !~ %r{(?!</?ol>|</?p>|<a\s+([^>]+)>((?:.(?!</a>))*.)</a>|</?a>)</?[^>]*>}

    raise IncompleteEntity, "Certain HTML attributes are not permitted."
  end

  def round_number
    return nil unless response_round_id.present?

    response_round.round_number
  end

  def validate_answers
    return true if !response_round.questions.present? && !answers.present?

    mandatory_question_ids = response_round.questions.filter do |question|
      !question.is_optional && !question.accept_voice_message
    end.map(&:id)
    raise IncompleteEntity, "Mandatory question should be answered." if mandatory_question_ids.present? && !answers.present?

    return unless answers.present?

    mandatory_question_ids.each do |question_id|
      question = response_round.questions.find_by(id: question_id)
      next if question&.accept_voice_message

      mandatory_answer = JSON.parse(answers.to_json).select { |answer| answer["question_id"] == question_id.to_s } if answers.instance_of?(Array)
      if !mandatory_answer.present? || (!mandatory_answer.first["answer"].present? && !mandatory_answer.first["other_option_answer"].present?)
        raise IncompleteEntity,
              "Mandatory question with id #{question_id} should be answered."
      end
    end

    validate_selected_options_limit
  end

  def notify_admin_if_profane
    return unless response_status == "under_review"

    NotifyProfaneResponseEmailToAdminJob.perform_later(self)
  end

  def approve
    self.approved_by_id = Current.user.id
    self.response_status = :acceptable
    self.approved_at = DateTime.now
    save!
  end

  def theme
    consultation.department.theme&.name
  end

  def submitted_by
    user ? user.full_name : "#{first_name} #{last_name}"
  end

  def responder_email
    user ? user.email : email
  end

  def city
    user.present? && user.city.present? ? user.city.name : 'NA'
  end

  def phone_number
    user.present? && user.phone_number.present? ? user.phone_number : 'NA'
  end

  def is_verified
    user ? user.confirmed_at? : nil
  end

  def submitted_at
    platform? ? created_at.localtime.try(:strftime, '%e %b %Y') : responded_at.try(:strftime, '%e %b %Y')
  end

  def organisation
    user.present? && user.organisation.present? ? user.organisation.name : 'NA'
  end

  def designation
    user.present? && user.designation.present? ? user.designation : 'NA'
  end

  def user_answers
    answers_hash = {}

    response_round.questions.each do |question|
      answer_data = if answers.present?
                      answers.find { |ans| ans['question_id'].to_i == question.id }
                    else
                      nil
                    end

      formatted_answer = if answer_data.present?
                           answer_text = if answer_data['answer'].is_a?(Array)
                                          format_multiple_choice_answer(answer_data)
                                        elsif answer_data['answer'].is_a?(Integer)
                                          Question.find(answer_data['answer']).question_text
                                        else
                                          answer_data['answer']
                                        end

                           empty_string = answer_data.key?('is_other') && answer_data['answer'].present? ? ',' : ' '

                           other_option_answer = if answer_data.key?('is_other')
                                                   other_answer = answer_data['other_option_answer']
                                                   if other_answer.is_a?(Hash)
                                                     "Option: #{other_answer['option_id']} Priority: #{other_answer['priority']}"
                                                   else
                                                     other_answer
                                                   end
                                                 else
                                                   ''
                                                 end

                           "#{answer_text} #{empty_string} #{other_option_answer}"
                         else
                           ''
                         end

      answers_hash[question.question_text] = formatted_answer
    end

    answers_hash
  end

  def reject
    self.rejected_by_id = Current.user.id
    self.response_status = :unacceptable
    self.rejected_at = DateTime.now
    save!
  end

  def self.import_responses(file)
    import_fields_from_files(file)
  end

  def check_if_consultation_expired?
    raise IncompleteEntity, "Consultation Expired" if platform? && consultation.response_deadline < Date.today
  end

  def set_subjective_objective_response_count
    if response_round.questions.present?
      # question_type can be regarded as response types
      response_types = response_round.questions.where(id: answers.map { |a| a["question_id"] }).pluck(:question_type)
      self.subjective_answer_count = response_types.count("long_text")
      self.objective_answer_count = response_types.count - subjective_answer_count
    else
      # if no questions present then it's a generic subjective response
      self.subjective_answer_count = 1
    end
  end

  private

  def validate_selected_options_limit
    questions = response_round.questions
    return if questions.blank? || answers.blank?

    questions.each do |question|
      next if question.selected_options_limit.to_i.zero?

      answer = answers.find { |ans| ans['question_id'] == question.id }
      next unless answer.is_a?(Array)

      raise BadRequest, 'Answer Limit is breached' if answer.size > question.selected_options_limit.to_i
    end
  end

  def format_multiple_choice_answer(answer)
    answer['answer'].map do |sub_question|
      if sub_question.is_a?(Hash)
        "Option: #{Question.find(sub_question['option_id']).question_text} Priority: #{sub_question['priority']}"
      elsif sub_question.is_a?(String)
        Question.find(sub_question).question_text
      else
        ''
      end
    end.join(',')
  end
end
