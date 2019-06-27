module Queries
	module Constant
		class ForType < Queries::BaseQuery
	    description "Get a list of locations"
	    argument :constant_type,             String, required: false, default_value: nil

	    type [Types::Objects::Constant], null: false

	    def resolve(constant_type:)
	    	::Constant.where(constant_type: constant_type)
	    end
		end
	end
end