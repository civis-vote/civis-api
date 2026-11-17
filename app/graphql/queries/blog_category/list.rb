module Queries
	module BlogCategory
		class List < Queries::BaseQuery
	    description "Get a list of blog categories"
	    argument :page,							Int,		required: false, default_value: 1
	    argument :per_page,					Int,		required: false, default_value: 50

	    type Types::Objects::BlogCategory::List, null: true

	    def resolve(per_page:, page:)
	    	::BlogCategory.order(:name).list(per_page, page)
	    end
		end
	end
end
