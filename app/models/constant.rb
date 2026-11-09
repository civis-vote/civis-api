class Constant < ApplicationRecord
  include CmAdmin::Constant
  include Paginator

  has_many :children, class_name: "Constant", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Constant", optional: true

  enum :constant_type, ::CONSTANT_TYPES

  scope :constant_type_filter, lambda { |constant_type|
    return all unless constant_type.present?

    where(constant_type: constant_type)
  }

  scope :sort_records, lambda { |sort, sort_direction = "asc"|
    return nil if sort.blank?

    order("#{sort} #{sort_direction}")
  }
end
