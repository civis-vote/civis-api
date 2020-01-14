module Queries
	module CaseStudy
		class Profile < Queries::BaseQuery
	    description "Get a single case study"
	    argument :id,		Int,		required: true

	    type Types::Objects::CaseStudy::Base, null: true

	    def resolve(id:)
	    	::CaseStudy.find(id)
	    end
		end
	end
end