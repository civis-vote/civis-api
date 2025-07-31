module Queries
	module Consultation
		class List < Queries::BaseQuery
	    description "Get a list of consultations"
	    argument :featured_filter,	Boolean,required: false, default_value: nil
	    argument :ministry_filter,	Int,		required: false, default_value: nil
	    argument :category_filter,	Int,		required: false, default_value: nil
	    argument :page,							Int,		required: false, default_value: 1
	    argument :per_page,					Int,		required: false, default_value: 20
	    argument :sort,							Types::Enums::ConsultationSorts, 	required: false, default_value: nil
	    argument :sort_direction,		Types::Enums::SortDirections,		required: false, default_value: nil
	    argument :status_filter,		String, required: false, default_value: nil

	    type Types::Objects::Consultation::List, null: true

	    def resolve(featured_filter:, status_filter:, ministry_filter:, category_filter:, per_page:, page:, sort:, sort_direction:)
	    	::Consultation.includes(:anonymous_responses).public_consultation.featured_filter(featured_filter).status_filter(status_filter).ministry_filter(ministry_filter).category_filter(category_filter).sort_records(sort, sort_direction).list(per_page, page)
	    end
		end
	end
end