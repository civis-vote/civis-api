module Queries
	module Glossary
		class Profile < Queries::BaseQuery
	    description "Get a single case study"
	    argument :id,		String,		required: true

	    type [Types::Objects::GlossaryMapping::Base], null: true

	    def resolve(id:)
	    	::GlossaryMapping.where(consultation_id: id)
	    end
		end
	end
end