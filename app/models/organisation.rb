class Organisation < ApplicationRecord
  acts_as_paranoid
  include ImageResizer
  include SpotlightSearch
  include Paginator
  include CmAdmin::Organisation

  has_one_attached :logo

  has_many :users, -> { active }, dependent: :nullify
  has_many :respondents
  has_many :respondent_users, -> { distinct }, through: :respondents, source: :user

  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User"
  validates_presence_of :created_by_id
  accepts_nested_attributes_for :users, allow_destroy: true, reject_if: proc { |attributes| attributes['email'].blank? }

  before_validation :set_created_by, on: :create

  scope :search_query, lambda { |query = nil|
    return nil unless query

    where("name ILIKE (?)", "%#{query}%")
  }

  scope :active, -> { where(active: true) }

  delegate :url, to: :logo, prefix: true, allow_nil: true
  delegate :full_name, to: :created_by, prefix: true, allow_nil: true

  def picture_url
    if logo.attached?
      logo_url
    else
      "user_profile_picture.png"
    end
  end

  def deactivate
    self.active = false
    save
  end

  private

  def set_created_by
    self.created_by = Current.user
  end
end
