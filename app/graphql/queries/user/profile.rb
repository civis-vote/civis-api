module Queries
	module User
		class Profile < Queries::BaseQuery
	    description "Get a single user"
	    argument :id,		Int,		required: true

	    type Types::Objects::User::CurrentUser, null: false

	    def resolve(id:)
	    	::User.find(id)
	    end
		end
	end
end