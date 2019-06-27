module Queries
	module Location
		class List < Queries::BaseQuery
	    description "Get a list of locations"
	    argument :type,             String, required: false, default_value: nil
	    argument :parent_id,        Int,		required: false, default_value: nil

	    type [Types::Objects::Location], null: false

	    def resolve(type:, parent_id:)
	    	::Location.location_type_filter(type).parent_filter(parent_id)
	    end
		end
	end
end