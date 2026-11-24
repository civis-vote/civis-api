class Theme < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  CIVIS_THEMES = {
    "Accessibility" => "fas fa-universal-access",
    "Agriculture" => "fas fa-leaf",
    "Consumer Affairs" => "fas fa-cart-shopping",
    "Education" => "fas fa-book-open",
    "Energy" => "fas fa-bolt",
    "Environment" => "fas fa-tree",
    "Finance" => "fas fa-chart-line",
    "Food Safety" => "fas fa-utensils",
    "Gender" => "fas fa-venus-mars",
    "Health" => "fas fa-heart-pulse",
    "Industry" => "fas fa-gears",
    "Insurance" => "fas fa-shield-check",
    "Internet" => "fas fa-globe",
    "Labour" => "fas fa-briefcase",
    "Legal Affairs" => "fas fa-scale-balanced",
    "Media" => "fas fa-images",
    "Public Administration" => "fas fa-landmark",
    "Rural Development" => "fas fa-tractor",
    "Telecom" => "fas fa-satellite-dish",
    "Tourism" => "fas fa-plane",
    "Transport" => "fas fa-truck",
    "Urban Settlements" => "fas fa-city",
    "Youth and Sports" => "fas fa-person-running"
  }.freeze

  CIVIS_THEME_NAMES = CIVIS_THEMES.keys.freeze

  include Paginator
  include CmAdmin::Theme

  enum :status, {
    active: 0,
    disabled: 1
  }

  has_many :theme_maps, dependent: :destroy

  scope :search_query, lambda { |query = nil|
    return nil unless query

    where("name ILIKE (?)", "%#{query}%")
  }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return nil if sort.blank?

    order("#{sort} #{sort_direction}")
  }
end
