class BlogCategory < ApplicationRecord
  include Paginator
  include CmAdmin::BlogCategory

  has_many :blog_posts, dependent: :restrict_with_error

  has_one_attached :icon

  validates :name, presence: true
end
