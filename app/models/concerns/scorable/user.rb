module Scorable
  module User
    extend ActiveSupport::Concern
    include Scorable

    included do 

	    if respond_to? :after_commit
	      after_commit :add_user_created_points, on: :create
	    end

	    def add_user_created_points
	    	self.add_points(:user_created)
	    end
	  end

    def add_points(action)
    	point_scale = calculate_point_scale(action)
    	self.point_events.create(point_scale: point_scale, points: point_scale.points)
    end

    def calculate_point_scale(action)
    	if PointScale.where('upper_limit > ?', self.points).where(action: action).order(upper_limit: :asc).present?
    		point_scale = PointScale.where('upper_limit > ?', self.points).where(action: action).order(upper_limit: :asc).first
    		return point_scale
    	else
    		puts "Could not find point scale!"
    	end
    end
  end
end