class ConsultationResponse < ApplicationRecord
  include Paginator
  include Scorable::ConsultationResponse
  
  belongs_to :user
  belongs_to :consultation, counter_cache: true
  belongs_to :template, class_name: 'ConsultationResponse', optional: true, counter_cache: :templates_count
  has_many :template_children, class_name: 'ConsultationResponse', foreign_key: 'template_id'
  has_many :up_votes, -> { up }, class_name: 'ConsultationResponseVote'
  has_many :down_votes, -> { down }, class_name: 'ConsultationResponseVote'
  has_many :votes, class_name: 'ConsultationResponseVote'

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

  def up_vote_count
    return up_votes.size
  end

  def down_vote_count
    return down_votes.size
  end

  def voted_as(user = Current.user)
    user_vote = self.votes.find_by(user: user)
    return nil if user_vote.nil?
    return user_vote
  end


end