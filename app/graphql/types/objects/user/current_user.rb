module Types
	module Objects
		module User
			class CurrentUser < Base
				field :created_at,									Types::Objects::DateTime, nil, 	null: false
				field :email,												String, 									nil,	null: false
				field :notify_for_new_consultation, Boolean, 									nil, 	null: true
				field :phone_number,								String,										nil, 	null: true
			end
		end
	end
end