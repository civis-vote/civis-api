class ConsultationResponseVote < ApplicationRecord
  belongs_to :consultation_response
  belongs_to :user

  enum vote_direction: { up: 0, down: 1 }
end
