class ConsultationResponseVote < ApplicationRecord

  has_paper_trail

	# associations
  belongs_to :consultation_response
  belongs_to :user

  # validations
  validates_uniqueness_of :consultation_response_id, scope: :user_id

  # enums
  enum vote_direction: { up: 0, down: 1 }

  after_commit :refresh_consultation_response_vote_count

  def refresh_consultation_response_vote_count
    consultation_response.refresh_consultation_response_up_vote_count
    consultation_response.refresh_consultation_response_down_vote_count
  end
end
