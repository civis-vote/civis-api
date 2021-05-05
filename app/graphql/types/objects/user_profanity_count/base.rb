module Types
	module Objects
		module UserProfanityCount
			class Base < BaseObject
				graphql_name "BaseUserProfanityCountType"
				field :user_id,							Int, "user_id", null: false
				field :profanity_count,					Int, "profanity_count", null: false
				field :user,							Types::Objects::User::Base, nil, null: false
			end
		end
	end
end