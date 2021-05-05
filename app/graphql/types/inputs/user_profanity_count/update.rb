module Types
	module Inputs
		module UserProfanityCount
			class Update < Types::BaseInputObject
				graphql_name "CurrentUserProfaneCountInput"
				argument :profanity_count,											Int,	nil,	required: true
			end
		end
	end
end
