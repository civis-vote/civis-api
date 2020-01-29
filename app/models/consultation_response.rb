class ConsultationResponse < ApplicationRecord
  include Paginator
  include Scorable::ConsultationResponse
  has_rich_text :response_text

  belongs_to :user
  belongs_to :consultation, counter_cache: true
  belongs_to :template, class_name: 'ConsultationResponse', optional: true, counter_cache: :templates_count
  has_many :template_children, class_name: 'ConsultationResponse', foreign_key: 'template_id'
  has_many :up_votes, -> { up }, class_name: 'ConsultationResponseVote'
  has_many :down_votes, -> { down }, class_name: 'ConsultationResponseVote'
  has_many :votes, class_name: 'ConsultationResponseVote'
  before_commit :update_reading_time
  after_create :analysis_response

  enum satisfaction_rating: [:dissatisfied, :somewhat_dissatisfied, :somewhat_satisfied, :satisfied]

  enum visibility: { shared: 0, anonymous: 1 }

  # validations
  validates_uniqueness_of :consultation_id, scope: :user_id  

  # scopes
  scope :consultation_filter, lambda { |consultation_id|
    return all unless consultation_id.present?
    where(consultation_id: consultation_id)
  }

  scope :sort_records, lambda { |sort = "created_at", sort_direction = "asc"|
  	order("#{sort} #{sort_direction}")
  }

  def analysis_response
    AnalyseKeywordsForConsultationJob.perform_later(self)
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
    if self.reading_time.blank? || self.response_text.saved_change_to_body?
      if self.response_text && self.shared?
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
    end
  end

end