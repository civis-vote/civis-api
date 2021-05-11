module Queries
	module Glossary
		class List < Queries::BaseQuery
	    description "Get a list of glossary words"
	    argument :page,							Int,		required: false, default_value: 1
	    argument :per_page,					Int,		required: false, default_value: 10
	    argument :sort,							Types::Enums::GlossarySorts, 	required: false, default_value: nil
	    argument :sort_direction,		Types::Enums::SortDirections,		required: false, default_value: nil
	    argument :search_filter,		String, required: false, default_value: nil

	    type Types::Objects::GlossaryMapping::List, null: true

	    def resolve(search_filter:, per_page:, page:, sort:, sort_direction:)
	    	::GlossaryMapping.search(search_filter).sort_records(sort, sort_direction).list(per_page, page)
	    end
		end
	end
end