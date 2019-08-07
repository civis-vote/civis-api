class ConsultationResponse < ApplicationRecord
  include Paginator
  
  belongs_to :user
  belongs_to :consultation, counter_cache: true

  enum satisfaction_rating: [:dissatisfied, :somewhat_dissatisfied, :somewhat_satisfied, :satisfied]

  enum visibility: { shared: 0, anonymous: 1 }

  # scopes
  scope :consultation_filter, lambda { |consultation_id|
    return all unless consultation_id.present?
    where(consultation_id: consultation_id)
  }

  scope :sort_records, lambda { |sort = "created_at", sort_direction = "asc"|
  	order("#{sort} #{sort_direction}")
  }

end