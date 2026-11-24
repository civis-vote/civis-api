class ThemeMap < ApplicationRecord
  belongs_to :theme
  belongs_to :mappable, polymorphic: true
end
