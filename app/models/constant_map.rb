class ConstantMap < ApplicationRecord
  belongs_to :constant
  belongs_to :mappable, polymorphic: true
end
