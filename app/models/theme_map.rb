class ThemeMap < ApplicationRecord
  include Trackable

  belongs_to :theme
  belongs_to :mappable, polymorphic: true
end
