module Types
	module Inputs
		module UserProfanityCount
			class Create < Types::BaseInputObject
				graphql_name "UserProfanityCountInput"
				argument :user_id,Integer,	nil,	required: true
                argument :profanity_count,Integer, nil,    required: true
			end
		end
	end
end