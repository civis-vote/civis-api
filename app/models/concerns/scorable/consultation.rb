module Scorable
  module Consultation
    extend ActiveSupport::Concern
    include Scorable

    included do 

	    if respond_to? :after_commit
	      after_commit :add_consultation_created_points, on: :create
	    end

	    def add_consultation_created_points
	    	self.created_by.add_points(:consultation_created)
	    end
	  end
  end
end