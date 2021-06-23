module Queries
	module UserProfanityCount
		class User < Queries::BaseQuery
	    description "Get a single profanity_count"
	    argument :user_id,		Integer,		required: false

	    type Types::Objects::UserProfanityCount::Base, null: true

	    def resolve(user_id:)
	    	current_user_profanity=::UserProfanityCount.find_by(user_id:user_id)
			return current_user_profanity
	    end
		end
	end
end