class Constant < ApplicationRecord

	has_many :children, class_name: 'Constant', foreign_key: 'parent_id'
  belongs_to :parent, class_name: "Constant", optional: true

	enum constant_type: []
end
