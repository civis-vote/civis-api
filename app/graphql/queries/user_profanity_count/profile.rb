module Queries
	module UserProfanityCount
		class Profile < Queries::BaseQuery
	    description "Get a single profanity_count"
	    argument :user_id,		Int,		required: false

	    type Types::Objects::UserProfanityCount::Base, null: true

	    def resolve(user_id:)
	    	::UserProfanityCount.all
	    end
		end
	end
end