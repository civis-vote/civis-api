module Queries
	module Consultation
		class Profile < Queries::BaseQuery
	    description "Get a single consultation"
	    argument :id,		Int,		required: true

	    type Types::Objects::Consultation::Base, null: true

	    def resolve(id:)
	    	consultation = ::Consultation.find(id)
	    	return consultation if consultation.public_consultation?
	    	return consultation if context[:current_user].present? 
	    	raise CivisApi::Exceptions::Unauthorized
	    end
		end
	end
end