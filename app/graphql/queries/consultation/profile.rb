module Queries
	module Consultation
		class Profile < Queries::BaseQuery
	    description "Get a list of consultations"
	    argument :id,		Int,		required: true

	    type Types::Objects::Consultation::Base, null: true

	    def resolve(id:)
	    	::Consultation.find(id)
	    end
		end
	end
end