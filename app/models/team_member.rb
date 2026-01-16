class TeamMember < ApplicationRecord
  has_paper_trail

  enum :status, { inactive: 0, active: 1 }
  enum :member_type, { team: 0, advisory: 1 }

  include Attachable
  include CmAdmin::TeamMember
  has_one_attached :profile_picture

  validates :name, :designation, presence: true
  validates :profile_picture, presence: true

  scope :active_only, -> { active }
  scope :alphabetical, -> { order(Arel.sql("LOWER(name) ASC")) }

end
