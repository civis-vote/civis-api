class ShowcaseSlide < ApplicationRecord
  has_paper_trail

  include Attachable
  include Trackable
  include CmAdmin::ShowcaseSlide

  enum :status, %i[draft published archived]

  attr_writer :banner_type

  has_rich_text :description
  has_one_attached :image

  validates_presence_of :title

  def banner_type
    return @banner_type if @banner_type.present?

    if image.attached?
      'image'
    else
      (video_url.present? ? 'video' : nil)
    end
  end

  scope :status_filter, lambda { |status|
    return all unless status.present?

    where(status: status)
  }

  scope :published_only, -> { where(status: :published) }

  scope :ordered_by_position, -> { order(position: :asc) }

  def publish
    update(status: :published, published_at: Time.current)
  end

  def archive
    update(status: :archived, archived_at: Time.current)
  end
end
