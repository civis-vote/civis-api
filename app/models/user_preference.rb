class UserPreference < ApplicationRecord
  belongs_to :user
  belongs_to :preferable, polymorphic: true

  validates :preferable_id, uniqueness: { scope: %i[user_id preferable_type] }
end
