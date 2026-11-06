class BlogCategory < ApplicationRecord
  include Paginator
  include CmAdmin::BlogCategory

  has_many :blog_posts, dependent: :restrict_with_error

  validates :name, presence: true
  validates :hex_code, format: { with: /\A#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})\z/ }, allow_blank: true
end
