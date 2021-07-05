module Types
	module Objects
		module UserCount
			class Base < BaseObject
				graphql_name "BaseUserCountType"
				field :user_id,							Integer, "user_id", null: false
				field :profanity_count,					Integer, "profanity_count", null: false
				field :short_response_count,					Integer, "short_response_count", null: false
			end
		end
	end
end