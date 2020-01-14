module Queries
	module Consultation
		class Analysis < Queries::BaseQuery
	    description "Keyword analysis based on consultation responses"
	    argument :id,		Int,		required: true
	    
	    type GraphQL::Types::JSON, null: true

	    def resolve(id:)
	    	consultation_keyword_analysis_hash = Rails.cache.read("consultation_keyword_analysis_#{id}")
	    	return consultation_keyword_analysis_hash
	    end
		end
	end
end
