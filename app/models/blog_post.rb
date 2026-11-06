class BlogPost < ApplicationRecord
  has_paper_trail

  include Trackable
  include Paginator
  include CmAdmin::BlogPost

  enum :status, %i[draft published archived]

  has_one_attached :featured_image
  has_rich_text :content

  belongs_to :blog_category

  validates :title, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, uniqueness: true, allow_nil: true

  before_save :set_slug, if: :will_save_change_to_title?

  delegate :name, to: :blog_category, prefix: true, allow_nil: true

  scope :search, lambda { |query|
    return nil if query.blank?

    # "*" acts as a wildcard; every term is wrapped in "%" and matched against title or description
    terms = query.downcase.split(/\s+/).map { |term| "%#{term.tr('*', '%')}%".squeeze("%") }
    where(
      Array.new(terms.size, "(LOWER(title) LIKE ? OR LOWER(description) LIKE ?)").join(" OR "),
      *terms.flat_map { |term| [term, term] }
    )
  }

  scope :blog_category_filter, ->(blog_category_id) { where(blog_category_id:) if blog_category_id.present? }
  scope :year_filter, ->(year) { where("EXTRACT(YEAR FROM published_at) = ?", year) if year.present? }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return nil if sort.blank?

    order("#{sort} #{sort_direction}")
  }

  def self.published_years
    published.where.not(published_at: nil)
             .distinct.pluck(Arel.sql("EXTRACT(YEAR FROM published_at)::int")).sort.reverse
  end

  def publish
    update(status: :published, published_at: Time.current)
  end

  def archive
    update(status: :archived, archived_at: Time.current)
  end

  private

  def set_slug
    self.slug = title.parameterize
  end
end
