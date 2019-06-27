module Queries
	module Ministry
		class Autocomplete < Queries::BaseQuery
	    description "Get an autocomplete list of ministry"
	    argument :q,	String, required: false, default_value: nil
	    type [Types::Objects::Ministry], null: false

	    def resolve(q:)
	    	::Ministry.search(q).approved.alphabetical
	    end

	    def self.accessible?(context)
        context[:current_user].present?
      end
		end
	end
end