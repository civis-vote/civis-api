module Types
	module Objects
		module User
			class CurrentUser < Base
				field :callback_url,								String,										nil,	null: true
				field :created_at,									Types::Objects::DateTime, nil, 	null: false
				field :confirmed_at,								Types::Objects::DateTime, nil, 	null: true
				field :designation,									String,										nil,	null: true
				field :email,												String, 									nil,	null: false
				field :last_name, 									String, 									nil, 	null: true
				field :notify_for_new_consultation, Boolean, 									nil, 	null: true
				field :organization, 								String,										nil,	null: true
				field :phone_number,								String,										nil, 	null: true
        field :is_verified,                 Boolean,                  nil, null: true
				field :responses,										Types::Connections::ConsultationResponse, nil, null: true do 
					argument :sort,										Types::Enums::ConsultationResponseSorts, 	required: false, default_value: nil
					argument :sort_direction,					Types::Enums::SortDirections, 						required: false, default_value: nil
				end

				def responses(sort:, sort_direction:)
					object.responses.sort_records(sort, sort_direction)
				end

        def is_verified
          object.confirmed_at? if object
        end
			end
		end
	end
end
