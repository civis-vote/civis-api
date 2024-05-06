class Organisation < ApplicationRecord
  acts_as_paranoid
	include ImageResizer
  include SpotlightSearch
  include Paginator
  include ImageUploader::Attachment(:logo)

  has_many :users, -> { active }, dependent: :nullify
  has_many :respondents
  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User"
  validates_presence_of :created_by_id
  accepts_nested_attributes_for :users, allow_destroy: true, reject_if: proc { |attributes| attributes['email'].blank? }

  scope :search_query, lambda { |query = nil|
    return nil unless query
    where("name ILIKE (?)", "%#{query}%")
  }
  
  scope :active, -> { where(active: true) }
 
  def picture_url
    if self.logo
      self.logo_url
    else
      "user_profile_picture.png"
    end
  end

  def deactivate
    self.active = false
    self.save
  end
end
