class ShowcaseSlide < ApplicationRecord
  has_paper_trail

  include Attachable
  include Trackable
  include CmAdmin::ShowcaseSlide

  enum :status, %i[draft published archived]

  has_rich_text :description
  has_one_attached :image

  validates_presence_of :title, :description, :cta_label, :cta_url, :position

  scope :ordered_by_position, -> { order(position: :asc) }

  def publish
    update(status: :published, published_at: Time.current)
  end

  def archive
    update(status: :archived, archived_at: Time.current)
  end
end
