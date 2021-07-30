module Queries
	module Profanity
		class List < Queries::BaseQuery
	    description "Get a list of profane words"
	    argument :page,						Int,		required: false, default_value: 1
	    argument :per_page,					Int,		required: false, default_value: 10
	    argument :sort,						Types::Enums::ProfanitySorts, 	required: false, default_value: nil
	    argument :sort_direction,			Types::Enums::SortDirections,	required: false, default_value: nil

	    type Types::Objects::Profanity::List, null: true

	    def resolve(per_page:, page:, sort:, sort_direction:)
			total_count = ::Profanity.total_profanity_count
	    	::Profanity.sort_records(sort, sort_direction).list(total_count, page)
	    end
		end
	end
end