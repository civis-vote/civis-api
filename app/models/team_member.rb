class TeamMember < ApplicationRecord
  has_paper_trail

  enum :status, { inactive: 0, active: 1 }
  enum :member_type, { team: 0, advisory: 1 }

  include Attachable
  include CmAdmin::TeamMember
  has_one_attached :profile_picture

  validates :name, :designation, presence: true
  validates :profile_picture, presence: true
  validate :validate_profile_picture_extension

  scope :active_only, -> { active }
  scope :alphabetical, -> { order(Arel.sql("LOWER(name) ASC")) }

  private

  def validate_profile_picture_extension
    return unless profile_picture.attached?
    return if %w[image/jpeg image/png image/jpg].include?(profile_picture.content_type)

    errors.add(:profile_picture, 'must be a JPG or PNG image')
  end

end
