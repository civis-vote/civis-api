module Queries
	module UserCount
		class User < Queries::BaseQuery
	    	description "Get a single user_count_record"
		    argument :user_id,		Integer,		required: false

		    type Types::Objects::UserCount::Base, null: true

	    	def resolve(user_id:)
	    		current_user_count=::UserCount.find_by(user_id:user_id)
				return current_user_count
		    end
		end
	end
end