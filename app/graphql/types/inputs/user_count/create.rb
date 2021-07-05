module Types
	module Inputs
		module UserCount
			class Create < Types::BaseInputObject
				graphql_name "UserCountInput"
				argument :user_id,Integer,	nil,	required: true
                argument :profanity_count,Integer, nil,    required: true
				argument :short_response_count,Integer, nil, 	required: true
			end
		end
	end
end