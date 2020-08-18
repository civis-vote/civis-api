module Queries
	module Consultation
		class Analysis < Queries::BaseQuery
	    description "Keyword analysis based on consultation responses"
	    argument :id,		Int,		required: true
	    
	    type GraphQL::Types::JSON, null: true

	    def resolve(id:)
	    	return nil
	    end
		end
	end
end
