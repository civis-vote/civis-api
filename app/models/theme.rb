class Theme < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  include Attachable
  include Paginator
  include CmAdmin::Theme

  has_many :departments
  has_many :constant_maps, as: :mappable, dependent: :destroy
  has_many :segments, -> { segment }, through: :constant_maps, source: :constant

  has_one_attached :cover_photo

  delegate :url, to: :cover_photo, prefix: true, allow_nil: true

  def segment_names
    segments.map(&:name).join(", ")
  end

  def picture_url
    if cover_photo.attached?
      cover_photo_url
    else
      "user_profile_picture.png"
    end
  end

  scope :search_query, lambda { |query = nil|
    return nil unless query

    where("name ILIKE (?)", "%#{query}%")
  }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return nil if sort.blank?

    order("#{sort} #{sort_direction}")
  }
end
