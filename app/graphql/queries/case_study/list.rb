module Queries
	module CaseStudy
		class List < Queries::BaseQuery
	    description "Get a list of case studies"
	    argument :page,							Int,		required: false, default_value: 1
	    argument :per_page,					Int,		required: false, default_value: 20
	    argument :sort,							Types::Enums::CaseStudySorts, 	required: false, default_value: nil
	    argument :sort_direction,		Types::Enums::SortDirections,		required: false, default_value: nil
	    argument :search_filter,		String, required: false, default_value: nil

	    type Types::Objects::CaseStudy::List, null: true

	    def resolve(search_filter:, per_page:, page:, sort:, sort_direction:)
	    	::CaseStudy.search(search_filter).sort_records(sort, sort_direction).list(per_page, page)
	    end
		end
	end
end