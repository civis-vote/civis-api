class ConsultationResponse < ApplicationRecord
  belongs_to :user
  belongs_to :consultation, counter_cache: true

  enum satisfaction_rating: [:dissatisfied, :somewhat_dissatisfied, :somewhat_satisfied, :satisfied]
end