module Types
	module Inputs
		module Auth
			class ChangePassword < Types::BaseInputObject
				graphql_name "AuthUpdatePasswordInput"
				argument :old_password,										String,		nil,	required: true
				argument :new_password,										String,		nil,	required: true
			end
		end
	end
end