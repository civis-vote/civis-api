module Scorable
  module PointEvent
    extend ActiveSupport::Concern
    include Scorable

    included do 

	    if respond_to? :after_commit
	      after_commit :add_points_to_user, on: :create
	    end

	    def add_points_to_user
	    	current_points = self.user.points
        self.user.update(points: current_points + self.points)
	    end
	  end
  end
end