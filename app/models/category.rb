class Category < ApplicationRecord
  acts_as_paranoid
	include Attachable
	include ImageResizer
  include SpotlightSearch
  include Paginator
  include ImageUploader::Attachment(:cover_photo)

  # has_one_attached :cover_photo
  has_many :ministries
  
  class << self

    def attachment_types
      %w[cover_photo]
    end

  end

  def picture_url
    if self.cover_photo
      self.cover_photo_url
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
