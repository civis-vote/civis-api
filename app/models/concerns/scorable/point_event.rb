module Scorable
  module PointEvent
    extend ActiveSupport::Concern

    included do 

	    after_commit :add_points_to_user, on: :create if respond_to? :after_commit

	    def add_points_to_user
	    	current_points = self.user.points
        self.user.update(points: current_points + self.points)
	    end
	  end
  end
end