class Department < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  include Attachable
  include Scorable::Ministry
  include Paginator
  include CmAdmin::Department

  has_one_attached :logo

  validates :name, :level, presence: true

  # enums
  enum :level, %i[national state local]

  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User", optional: true

  has_many :consultations
  has_many :constant_maps, as: :mappable, dependent: :destroy
  has_many :segments, -> { segment }, through: :constant_maps, source: :constant
  has_many :department_contacts, dependent: :destroy

  store_accessor :meta, :approved_by_id, :rejected_by_id, :approved_at, :rejected_at

  before_validation :set_created_by, on: :create
  validate :validate_logo_image_extension, :presence_of_primary_contact

  delegate :url, to: :logo, prefix: true, allow_nil: true
  delegate :full_name, to: :created_by, prefix: true, allow_nil: true

  accepts_nested_attributes_for :department_contacts, allow_destroy: true, reject_if: :all_blank

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

  scope :department_name, ->(names) {
    return all unless names.present?
    where(name: names)
  }


  def picture_url
    if logo.attached?
      logo_url
    else
      "user_profile_picture.png"
    end
  end

  def primary_contact
    department_contacts.primary.first
  end

  def secondary_contact
    department_contacts.secondary.first
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

  def segment_names
    segments.map(&:name).join(", ")
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

  def duplicate
    fields = attributes.except('id', 'created_at', 'updated_at', 'is_approved', 'approved_at', 'rejected_at', 'created_by_id')
    department = ::Department.new(fields)
    department.name = "Copy of #{name}"
    department.created_by_id = Current.user&.id
    department.department_contacts_attributes = department_contacts.map do |department_contact|
      department_contact.attributes.except('id', 'created_at', 'updated_at', 'department_id')
    end
    department.save!
    department.logo.attach(logo.blob)
  end

  private

  def validate_logo_image_extension
    return unless logo.attached? && %w[image/jpeg image/png image/jpg].exclude?(logo.content_type)

    errors.add(:logo, 'must be a JPG or PNG image')
  end

  def presence_of_primary_contact
    active_contacts = department_contacts.reject(&:marked_for_destruction?)
    has_primary = active_contacts.any? { |contact| contact.contact_type == 'primary' }
    errors.add(:base, 'Department must have at least one primary contact') unless has_primary
  end

  def set_created_by
    self.created_by = Current.user
  end
end
