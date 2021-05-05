module Types
	module Inputs
		module UserProfanityCount
			class Create < Types::BaseInputObject
				graphql_name "CreateNewUserProfaneCount"
				argument :user_id,											Int,	nil,	required: true
                argument :profanity_count,                                   Int, nil,    required: true
			end
		end
	end
end
