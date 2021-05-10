class ConsultationResponse < ApplicationRecord
  acts_as_paranoid
  include Paginator
  include Scorable::ConsultationResponse
  has_rich_text :response_text

  belongs_to :user, optional: true
  belongs_to :consultation, counter_cache: true, optional: true
  validates_uniqueness_of :user_id, scope: :response_round_id, unless: Proc.new { |user| user_id.blank? }
  belongs_to :template, class_name: "ConsultationResponse", optional: true, counter_cache: :templates_count
  has_many :template_children, class_name: "ConsultationResponse", foreign_key: "template_id"
  has_many :up_votes, -> { up }, class_name: "ConsultationResponseVote"
  has_many :down_votes, -> { down }, class_name: "ConsultationResponseVote"
  has_many :votes, class_name: "ConsultationResponseVote"
  belongs_to :respondent, optional: true
  belongs_to :response_round
  before_commit :update_reading_time
  before_commit :validate_html_tags
  before_commit :validate_answers, on: :create

  enum satisfaction_rating: [:dissatisfied, :somewhat_dissatisfied, :somewhat_satisfied, :satisfied]

  enum visibility: { shared: 0, anonymous: 1 }
  enum source: { platform: 0, off_platform: 1 }

  # validations
  # validates_uniqueness_of :consultation_id, scope: :user_id  

  # scopes
  scope :consultation_filter, lambda { |consultation_id|
    return all unless consultation_id.present?
    where(consultation_id: consultation_id)
  }

  scope :sort_records, lambda { |sort = "created_at", sort_direction = "asc"|
  	order("#{sort} #{sort_direction}")
  }

  def self.public_consultation_response_filter
    joins(:consultation).where(consultations: { visibility: 'public_consultation'} )
  end

  def refresh_consultation_response_up_vote_count
    update(up_vote_count: up_votes.size)
  end

  def refresh_consultation_response_down_vote_count
    update(down_vote_count: down_votes.size)
  end

  def voted_as(user = Current.user)
    user_vote = self.votes.find_by(user: user)
    return nil if user_vote.nil?
    return user_vote
  end

  def update_reading_time
    return unless self.reading_time.blank? || self.response_text.saved_change_to_body?
    return unless self.response_text && self.shared?
    total_word_count = self.response_text.body.to_plain_text.scan(/\w+/).size
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

  def validate_html_tags
    return response_text.body.blank?
    if response_text.body.to_html !~ /(?!<\/?ol>|<\/?p>|<a[\s]+([^>]+)>((?:.(?!\<\/a\>))*.)<\/a>|<\/?a>)<\/?[^>]*>/
      return true
    else
      raise CivisApi::Exceptions::IncompleteEntity, "Certain HTML attributes are not permitted."
    end
  end

  def round_number
    return nil unless response_round_id.present?
    return response_round.round_number
  end

  def validate_answers
    return true if ( !response_round.questions.present? && !answers.present? )
    mandatory_question_ids = []
    response_round.questions.map{|question| mandatory_question_ids << question.id if question.is_optional == false }
    raise CivisApi::Exceptions::IncompleteEntity, "Mandatory question should be answered." if ( mandatory_question_ids.present? && !answers.present? )
    if answers.present?
      mandatory_question_ids.each do |question_id|
      	if answers.class == Array
      		mandatory_answer = JSON.parse(answers.to_json).select { |answer| answer["question_id"] == question_id.to_s }
      	else
        	mandatory_answer = YAML.load(answers).select { |answer| answer["question_id"] == question_id.to_s }
      	end
        raise CivisApi::Exceptions::IncompleteEntity, "Mandatory question with id #{question_id} should be answered." if ( !mandatory_answer.present? || (!mandatory_answer.first["answer"].present? && !mandatory_answer.first["other_option_answer"].present?) )
      end
    end
  end
end