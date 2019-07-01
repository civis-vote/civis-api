class Consultation < ApplicationRecord
	include Paginator

  belongs_to :ministry
  belongs_to :created_by, foreign_key: 'created_by_id', class_name: 'User', optional: true
  has_many :responses, class_name: "ConsultationResponse"
  has_many :shared_responses, -> { shared }, class_name: "ConsultationResponse"
  has_many :anonymous_responses, -> { anonymous }, class_name: "ConsultationResponse"

  enum status: [:submitted, :published, :rejected, :expired]

  scope :status_filter, lambda { |status|
    return all unless status.present?
    where(status: status)
  }

  scope :ministry_filter, lambda { |ministry_id|
    return all unless ministry_id.present?
    where(ministry_id: ministry_id)
  }

  def publish
  	self.status = :published
  	self.published_at = DateTime.now
  	self.save!
  end

  def reject
  	self.update(status: :rejected)
  end

  def expire
  	self.update(status: :expired)
  end

end