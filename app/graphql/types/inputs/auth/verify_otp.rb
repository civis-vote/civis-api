module Types
	module Inputs
		module Auth
			class VerifyOtp < Types::BaseInputObject
				argument :email, 												String, 	nil, 	required: true
				argument :otp, 													String, 	nil, 	required: true
			end
		end
	end
end