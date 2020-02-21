module Scorable
  module ConsultationResponse
    extend ActiveSupport::Concern
    include Scorable

    included do 

	    after_commit :add_response_created_points, on: :create if respond_to? :after_commit

	    def add_response_created_points
	    	points_to_add = 0.0
	    	point_event = self.user.add_points(:response_submitted)
	    	points_to_add += point_event.points
	    	if self.shared?
	    		point_event = self.user.add_points(:public_response_submitted)
	    		points_to_add += point_event.points
	    	end
	    	self.update(points: points_to_add)
	    	self.template.user.add_points(:response_used) if self.template.present?
	    end
	  end
  end
end