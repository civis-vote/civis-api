module Queries
	module Consultation
		class Profile < Queries::BaseQuery
	    description "Get a single consultation"
	    argument :id,		Int,		required: true

	    type Types::Objects::Consultation::Base, null: true

	    def resolve(id:)
	    	consultation = ::Consultation.find(id)
	    	raise CivisApi::Exceptions::Unauthorized if (!context[:current_user].present? && consultation.private_consultation?) 
	    	return consultation
	    end
		end
	end
end