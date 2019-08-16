class ConsultationResponseVote < ApplicationRecord

	# associations
  belongs_to :consultation_response
  belongs_to :user

  # validations
  validates_uniqueness_of :consultation_response_id, scope: :user_id

  # enums
  enum vote_direction: { up: 0, down: 1 }
end
