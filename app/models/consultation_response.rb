class ConsultationResponse < ApplicationRecord
  belongs_to :user
  belongs_to :consultation, counter_cache: true

  enum satisfaction_rating: [:dissatisfied, :somewhat_dissatisfied, :somewhat_satisfied, :satisfied]

  enum visibility: { shared: 0, anonymous: 1 }
end