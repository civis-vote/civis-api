class Consultation < ApplicationRecord
  include SpotlightSearch
	include Paginator
  include Scorable::Consultation
  has_rich_text :summary

  belongs_to :ministry
  belongs_to :created_by, foreign_key: 'created_by_id', class_name: 'User', optional: true
  has_many :responses, class_name: "ConsultationResponse"
  has_many :shared_responses, -> { shared }, class_name: "ConsultationResponse"
  has_many :anonymous_responses, -> { anonymous }, class_name: "ConsultationResponse"

  enum status: { submitted: 0, published: 1, rejected: 2, expired: 3 }

  scope :status_filter, lambda { |status|
    return all unless status.present?
    where(status: status)
  }

  scope :ministry_filter, lambda { |ministry_id|
    return all unless ministry_id.present?
    where(ministry_id: ministry_id)
  }

  scope :featured_filter, lambda { |featured|
    return all unless featured.present?
    where(is_featured: featured)
  }

  scope :search_query, lambda { |query = nil|
    return nil unless query
    where('title ILIKE (?)', "%#{query}%")
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

  def responded_on(user = Current.user)
    user_response = self.responses.find_by(user: user)
    return nil if user_response.nil?
    return user_response.created_at
  end

  def satisfaction_rating_distribution
    self.responses.group(:satisfaction_rating).distinct.count(:satisfaction_rating)
  end

  def featured
    self.update(is_featured: true)
  end

  def unfeatured
    self.update(is_featured: false)
  end

end