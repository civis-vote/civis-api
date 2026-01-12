class TeamMember < ApplicationRecord
  has_paper_trail

  include Attachable
  include Paginator
  include CmAdmin::TeamMember
  has_one_attached :profile_picture

  enum member_type: { team: 0, advisory: 1 }

  validates :name, :designation, presence: true
  validates :profile_picture, presence: true

  scope :alphabetical, -> {
    order(Arel.sql("LOWER(name) ASC"))
  }

  def status
    active ? :active : :inactive
  end

end
