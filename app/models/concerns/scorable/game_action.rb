module Scorable
  module GameAction
    extend ActiveSupport::Concern
    include Scorable

    included do 

	    if respond_to? :after_commit
	      after_commit :add_points, on: :create
	    end

	    def add_points
	    	self.user.add_points(self.action)
	    end
	  end
  end
end