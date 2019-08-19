module Scorable
  module Ministry
    extend ActiveSupport::Concern
    include Scorable

    included do 

	    if respond_to? :after_commit
	      after_commit :add_ministry_created_points, on: :create
	    end

	    def add_ministry_created_points
	    	self.created_by.add_points(:ministry_created)
	    end
	  end
  end
end