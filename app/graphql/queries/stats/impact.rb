module Queries
	module Stats
		class Impact < Queries::BaseQuery
	    description "Get impact stats for Civis"
	    type GraphQL::Types::JSON, null: false

	    def resolve
	    	consultation_count = ::Consultation.where(status: [:expired, :published]).count
	    	consultation_response_count = ::ConsultationResponse.count
	    	consultation_response_distinct_users = ::ConsultationResponse.distinct.pluck(:user_id).count
	    	registered_users = ::User.count
	    	return {
	    		consultation_count: consultation_count,
	    		consultation_response_count: consultation_response_count,
	    		consultation_response_distinct_users: consultation_response_distinct_users,
	    		total_registered_users: registered_users
	    	}
	    end
		end
	end
end