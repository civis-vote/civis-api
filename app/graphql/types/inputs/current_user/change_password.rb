module Types
	module Inputs
		module CurrentUser
			class ChangePassword < Types::BaseInputObject
				graphql_name "CurrentUserUpdatePasswordInput"
				argument :old_password,										String,		nil,	required: true
				argument :new_password,										String,		nil,	required: true
			end
		end
	end
end