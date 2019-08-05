module Types
	module Inputs
		module Auth
			class SignUp < Types::BaseInputObject
				description "Attributes for creating a user"

				argument :city_id,											Int,			nil,	required: true
				argument :email, 												String, 	nil, 	required: true
				argument :first_name, 									String, 	nil, 	required: true
				argument :last_name, 										String, 	nil, 	required: true
				argument :notify_for_new_consultation, 	Boolean,	nil,	required: false
				argument :password, 										String, 	nil, 	required: true
				argument :phone_number,									String,		nil, 	required: false
			end
		end
	end
end