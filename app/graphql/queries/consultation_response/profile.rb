module Queries
	module ConsultationResponse
		class Profile < Queries::BaseQuery
	    description "Get a single consultation response"
	    argument :id,		Int,		required: true

	    type Types::Objects::ConsultationResponse::Base, null: true

	    def resolve(id:)
	    	consultation_response = ::ConsultationResponse.find(id)
	    	return consultation_response if consultation_response.shared?
	    	return consultation_response if context[:current_user] == consultation_response.user
	    	raise Unauthorized
	    end
		end
	end
end