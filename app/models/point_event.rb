class PointEvent < ApplicationRecord

	include Scorable::PointEvent


  belongs_to :point_scale
  belongs_to :user
end
