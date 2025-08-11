class Ministry < ApplicationRecord
  acts_as_paranoid
  include Attachable
  include Scorable::Ministry
  include Paginator
  include CmAdmin::Ministry

  has_one_attached :logo

  validates :name, :level, :poc_email_primary, presence: true

  # enums
  enum level: %i[national state local]

  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User", optional: true
  belongs_to :category, optional: true

  has_many :consultations

  store_accessor :meta, :approved_by_id, :rejected_by_id, :approved_at, :rejected_at

  before_validation :set_created_by, on: :create

  delegate :url, to: :logo, prefix: true, allow_nil: true
  delegate :full_name, to: :created_by, prefix: true, allow_nil: true
  delegate :name, to: :category, prefix: true, allow_nil: true

  scope :approved, -> { where(is_approved: true) }
  scope :alphabetical, -> { order(name: :asc) }
  scope :status_filter, lambda { |status|
    return all unless status.present?

    where(is_approved: status)
  }

  scope :search, lambda { |query|
    return nil if query.blank?

    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map do |e|
      (e.gsub("*", "%").prepend("%") + "%").gsub(/%+/, "%")
    end
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conds = 1
    where(
      terms.map do |_term|
        "(LOWER(name) LIKE ?)"
      end.join(" OR "),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  def picture_url
    if logo.attached?
      logo_url
    else
      "user_profile_picture.png"
    end
  end

  def status
    is_approved ? 'approved' : 'not_approved'
  end

  def location
    return nil if location_id == 0

    Location.find_by(id: location_id)
  end

  def location_name
    location&.name
  end

  def approve
    self.approved_by_id = Current.user.id
    self.is_approved = true
    self.approved_at = DateTime.now
    save!
  end

  def reject
    self.rejected_by_id = Current.user.id
    self.is_approved = false
    self.rejected_at = DateTime.now
    save!
  end

  private

  def set_created_by
    self.created_by = Current.user
  end
end
