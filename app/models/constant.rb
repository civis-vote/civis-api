class Constant < ApplicationRecord

	has_many :children, class_name: 'Constant', foreign_key: 'parent_id'
  belongs_to :parent, class_name: "Constant", optional: true

	enum constant_type: [:ministry_category]

	scope :ministry_categories, -> { where(constant_type: :ministry_category) }
end