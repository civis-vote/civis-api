class BlogCategory < ApplicationRecord
  include Paginator
  include CmAdmin::BlogCategory

  has_many :blog_posts, dependent: :nullify

  validates :name, presence: true
end
