module Queries
	module Consultation
		class List < Queries::BaseQuery
	    description "Get a list of consultations"
	    argument :status_filter,		String, required: false, default_value: nil
	    argument :ministry_filter,	Int,		required: false, default_value: nil
	    argument :per_page,					Int,		required: false, default_value: 20
	    argument :page,							Int,		required: false, default_value: 1

	    type Types::Objects::Consultation::List, null: true

	    def resolve(status_filter:, ministry_filter:, per_page:, page:)
	    	::Consultation.status_filter(status_filter).ministry_filter(ministry_filter).list(per_page, page)
	    end
		end
	end
end