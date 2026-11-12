module Types
	module Inputs
		module Auth
			class Login < Types::BaseInputObject
				argument :email, 												String, 	nil, 	required: false
				argument :phone_number, 								String, 	nil, 	required: false
			end
		end
	end
end