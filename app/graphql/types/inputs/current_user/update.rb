module Types
	module Inputs
		module CurrentUser
			class Update < Types::BaseInputObject
				graphql_name "CurrentUserUpdateInput"
				argument :callback_url,									String,		nil,	required: false
				argument :city_id,											Integer,	nil,	required: false
				argument :designation,									String,		nil,	required: false
				argument :first_name,										String,		nil,	required: false
				argument :last_name,										String,		nil,	required: false
				argument :organization, 								String,		nil,	required: false
				argument :phone_number,									String,		nil,	required: false
				argument :profile_picture_file,					Types::Inputs::Attachment, nil, required: false
			end
		end
	end
end
