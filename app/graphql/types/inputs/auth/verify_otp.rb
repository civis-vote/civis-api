module Types
	module Inputs
		module Auth
			class VerifyOtp < Types::BaseInputObject
				argument :email, 												String, 	nil, 	required: false
				argument :phone_number, 								String, 	nil, 	required: false
				argument :otp, 													String, 	nil, 	required: true
			end
		end
	end
end