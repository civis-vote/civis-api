class TeamMember < ApplicationRecord
  has_paper_trail

  include Attachable
  include Paginator
  include CmAdmin::TeamMember
  has_one_attached :profile_picture

  validates :name, :designation, :position, presence: true
  validates :profile_picture, presence: true

  default_scope { order(:position) }

  def status
    active ? 'Active' : 'Inactive'
  end

end
