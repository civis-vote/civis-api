class TeamMember < ApplicationRecord
  has_paper_trail

  enum :status, { inactive: 0, active: 1 }
  enum :member_type, { team: 0, advisory: 1 }

  include Attachable
  include Paginator
  include CmAdmin::TeamMember
  
  has_one_attached :profile_picture

  validates :name, :designation, :profile_picture, presence: true
  validate :validate_profile_picture_extension

  scope :active_only, -> { active }
  
  scope :member_type_filter, lambda { |member_type|
    return all if member_type.blank?
    where(member_type: member_type)
  }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return alphabetical if sort.blank?
    order("#{sort} #{sort_direction}")
  }

  scope :alphabetical, -> { order(name: :asc) }

  private

  def validate_profile_picture_extension
    return unless profile_picture.attached?
    return if %w[image/jpeg image/png image/jpg].include?(profile_picture.content_type)

    errors.add(:profile_picture, 'must be a JPG or PNG image')
  end
end
