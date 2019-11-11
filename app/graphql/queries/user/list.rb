module Queries
	module User
		class List < Queries::BaseQuery
	    description "Get a list of users"
	    argument :role_filter,			Types::Enums::UserRoles,required: false, default_value: nil
	    argument :location_filter,	Integer,								required: false, default_value: nil
	    argument :per_page,					Integer,								required: false, default_value: 20
	    argument :page,							Integer,								required: false, default_value: 1
			argument :sort,							Types::Enums::UserSorts,required: false, default_value: nil
	    argument :sort_direction,		Types::Enums::SortDirections, 						required: false, default_value: nil

	    type Types::Objects::User::List, null: true

	    def resolve(role_filter:, location_filter:, per_page:, page:, sort:, sort_direction:)
	    	::User.role_filter(role_filter)
	    				.location_filter(location_filter)
	    				.sort_records(sort, sort_direction)
	    				.list(per_page, page)
	    end
		end
	end
end