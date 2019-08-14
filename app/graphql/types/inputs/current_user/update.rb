module Types
	module Inputs
		module CurrentUser
			class Update < Types::BaseInputObject
				graphql_name "CurrentUserUpdateInput"
				argument :city_id,											Integer,	nil,	required: false
				argument :first_name,										String,		nil,	required: false
				argument :last_name,										String,		nil,	required: false
				argument :phone_number,									String,		nil,	required: false
			end
		end
	end
end