module Queries
	module Glossary
		class Profile < Queries::BaseQuery
	    description "Get a single case study"
	    argument :id,		Int,		required: true

	    type Types::Objects::Glossary::Base, null: true

	    def resolve(id:)
	    	::Wordindex.find(id)
	    end
		end
	end
end