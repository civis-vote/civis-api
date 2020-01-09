module Queries
	module ConsultationResponse
		class VenterMap < Queries::BaseQuery
	    description "Get resonse keyword map for consultation responses"
	    type GraphQL::Types::JSON, null: false

	    def resolve
	    	hash_map_response = Rails.cache.read("response_hash_map")
	    	return hash_map_response
	    end
		end
	end
end