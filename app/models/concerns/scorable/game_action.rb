module Scorable
  module GameAction
    extend ActiveSupport::Concern
    include Scorable

    included do 

	    if respond_to? :after_commit
	      after_commit :add_points, on: :create
	    end

	    def add_points
	    	point_event = self.user.add_points(self.action)
	    	self.update(point_event: point_event)
	    end
	  end
  end
end