module Types
	module Inputs
		module Auth
			class Login < Types::BaseInputObject
				argument :email, 												String, 	nil, 	required: true
				argument :password, 										String, 	nil, 	required: true
			end
		end
	end
end