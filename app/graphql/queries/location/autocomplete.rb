module Queries
	module Location
		class Autocomplete < Queries::BaseQuery
	    description "Get an autocomplete list of locations"
	    argument :type,             String, required: false, default_value: nil
	    argument :parent_id,        Int,		required: false, default_value: nil
	    argument :q,								String, required: false, default_value: nil
      argument :is_international_city, Boolean, required: false, default_value: false
	    type [Types::Objects::Location], null: false

	    def resolve(q:, type:, parent_id:, is_international_city:)
	    	::Location.search(q).location_type_filter(type, is_international_city).parent_filter(parent_id).limit(20)
	    end
		end
	end
end