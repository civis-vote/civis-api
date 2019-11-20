module Scorable
  module Consultation
    extend ActiveSupport::Concern
    include Scorable

    included do 

	    if respond_to? :before_save
	      before_save :add_consultation_created_points, if: :status_changed?
	    end

	    def add_consultation_created_points
	    	self.created_by.add_points(:consultation_created) if self.status_changed?(from: :submitted, to: :published)
	    end
	  end
  end
end
