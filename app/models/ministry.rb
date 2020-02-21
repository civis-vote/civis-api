class Ministry < ApplicationRecord
	include Attachable
	include ImageResizer
  include Scorable::Ministry
  include SpotlightSearch
  include Paginator

	validates :name, :level,  presence: true

	# enums
  enum level: [:national, :state, :local]

  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User", optional: true
  has_one_attached :logo
  has_one_attached :cover_photo
  export_columns enabled: true, except: [:meta]
  store_accessor :meta, :approved_by_id, :rejected_by_id, :approved_at, :rejected_at

  class << self

    def attachment_types
      %w[logo cover_photo]
    end

  end

  scope :approved, -> { where(is_approved: true) }
  scope :alphabetical, -> { order(name: :asc) }
  scope :status_filter, lambda { |status|
    return all unless status.present?
    where(is_approved: status)
  }

  scope :search, lambda { |query|
    return nil  if query.blank?
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub("*", "%").prepend("%") + "%").gsub(/%+/, "%")
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conds = 1
    where(
      terms.map { |term|
        "(LOWER(name) LIKE ?)"
      }.join(" OR "),
      *terms.map { |e| [e] * num_or_conds }.flatten,
    )
  }

  def logo_url
    if self.logo.attached?
      self.logo
    else
      "media/application/images/user_profile_picture.png"
    end
  end

  def approve
    self.approved_by_id = Current.user.id
    self.is_approved = true
    self.approved_at = DateTime.now
    self.save!
  end

  def reject
    self.rejected_by_id = Current.user.id
    self.is_approved = false
    self.rejected_at = DateTime.now
    self.save!
  end

end
