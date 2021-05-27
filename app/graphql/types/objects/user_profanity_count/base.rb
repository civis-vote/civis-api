module Types
	module Objects
		module UserProfanityCount
			class Base < BaseObject
				graphql_name "BaseUserProfanityCountType"
				field :user_id,							Integer, "user_id", null: false
				field :profanity_count,					Integer, "profanity_count", null: false
			end
		end
	end
end