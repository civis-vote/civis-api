module Scorable
  module ConsultationResponse
    extend ActiveSupport::Concern
    include Scorable

    included do 

	    if respond_to? :after_commit
	      after_commit :add_response_created_points, on: :create
	    end

	    def add_response_created_points
	    	self.user.add_points(:response_submitted)
	    	self.user.add_points(:public_response_submitted) if self.shared?
	    end
	  end
  end
end