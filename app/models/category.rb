class Category < ApplicationRecord
  acts_as_paranoid
  include Attachable
  include Paginator
  include CmAdmin::Category

  has_many :ministries

  has_one_attached :cover_photo

  delegate :url, to: :cover_photo, prefix: true, allow_nil: true

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
