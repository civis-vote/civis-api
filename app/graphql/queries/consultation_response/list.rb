module Queries
	module ConsultationResponse
		class List < Queries::BaseQuery
	    description "Get a list of consultation responses"
	    argument :consultation_filter,		Int, 																			required: false, default_value: nil
	    argument :per_page,								Int,																			required: false, default_value: 20
	    argument :page,										Int,																			required: false, default_value: 1
	    argument :responses_from,					Types::Enums::ConsultationResponseSource, required: false, default_value: "platform"
	    argument :sort,										Types::Enums::ConsultationResponseSorts, 	required: false, default_value: nil
	    argument :sort_direction,					Types::Enums::SortDirections, 						required: false, default_value: nil

	    type Types::Objects::ConsultationResponse::List, null: true

	    def resolve(consultation_filter:, per_page:, page:, sort:, sort_direction:, responses_from:)
	    	if responses_from == "platform"
	    		consultation_response = ::ConsultationResponse.platform
	    	else
	    		consultation_response = ::ConsultationResponse.off_platform
	    	end
	    	consultation_response.includes(:user, :consultation).public_consultation_response_filter.consultation_filter(consultation_filter).shared.sort_records(sort, sort_direction).list(per_page, page)
	    end
		end
	end
end