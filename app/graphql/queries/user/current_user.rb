module Queries
	module User
		class CurrentUser < Queries::BaseQuery
	    description "Get the currently logged in user"

	    type Types::Objects::User::CurrentUser, null: false

	    def resolve
	    	context[:current_user]
	    end

	    def self.accessible?(context)
    		context[:current_user].present?
  		end
		end
	end
end