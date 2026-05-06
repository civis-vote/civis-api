class Constant < ApplicationRecord
  include CmAdmin::Constant

  has_many :children, class_name: "Constant", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Constant", optional: true

  enum :constant_type, ::CONSTANT_TYPES
end
