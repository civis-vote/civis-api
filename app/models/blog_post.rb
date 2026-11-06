class BlogPost < ApplicationRecord
  has_paper_trail

  include Attachable
  include Trackable
  include Paginator
  include CmAdmin::BlogPost

  enum :status, %i[draft published archived]

  has_one_attached :featured_image
  has_rich_text :content

  belongs_to :blog_category

  validates :title, presence: true, uniqueness: { case_sensitive: false }

  after_commit :update_slug

  delegate :name, :hex_code, to: :blog_category, prefix: true, allow_nil: true

  scope :search, lambda { |query|
    return nil if query.blank?

    terms = query.downcase.split(/\s+/)
    terms = terms.map do |e|
      (e.gsub("*", "%").prepend("%") + "%").gsub(/%+/, "%")
    end
    num_or_conds = 2
    where(
      terms.map do |_term|
        "(LOWER(title) LIKE ? OR LOWER(description) LIKE ?)"
      end.join(" OR "),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  scope :blog_category_filter, lambda { |blog_category_id|
    return nil if blog_category_id.blank?

    where(blog_category_id: blog_category_id)
  }

  scope :slug_filter, lambda { |slug|
    return nil if slug.blank?

    where(slug: slug)
  }

  scope :year_filter, lambda { |year|
    return nil if year.blank?

    where("EXTRACT(YEAR FROM published_at) = ?", year)
  }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return nil if sort.blank?

    order("#{sort} #{sort_direction}")
  }

  def publish
    update(status: :published, published_at: Time.current)
  end

  def archive
    update(status: :archived, archived_at: Time.current)
  end

  private

  def update_slug
    return unless saved_change_to_title?

    update_column(:slug, title.parameterize)
  end
end
