module Queries
	module ConsultationResponse
		class VenterMap < Queries::BaseQuery
	    description "Get resonse keyword map for consultation responses"
	    type GraphQL::Types::JSON, null: false

	    def resolve
	    	return nil
	    end
		end
	end
end