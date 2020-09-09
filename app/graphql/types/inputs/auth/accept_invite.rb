module Types
	module Inputs
		module Auth
			class AcceptInvite < Types::BaseInputObject
				argument :first_name, 									String, 	nil, 	required: true
				argument :last_name, 										String, 	nil, 	required: false
				argument :password, 										String, 	nil, 	required: true
				argument :invitation_token, 						String, 	nil, 	required: true
				argument :consultation_id,							Int,			nil,	required: true
			end
		end
	end
end