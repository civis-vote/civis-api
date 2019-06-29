class Consultation < ApplicationRecord
	include Paginator
	
  belongs_to :ministry
  belongs_to :created_by, foreign_key: 'created_by_id', class_name: 'User', optional: true

  enum status: [:submitted, :publised, :rejected, :expired]

  scope :status_filter, lambda { |status|
    return all unless status.present?
    where(status: status)
  }

  scope :ministry_filter, lambda { |ministry_id|
    return all unless ministry_id.present?
    where(ministry_id: ministry_id)
  }

end