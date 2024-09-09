module Types
	module Objects
		module ConsultationPartnerResponse
			class Base < BaseObject
				graphql_name "ConsultationPartnerResponseType"
				field :organisation_id, 												Integer, nil, null: false
				field :organisation, 														Types::Objects::Organisation::Base, nil, null: true
				field :response_count, 												Integer, nil, null: false

				def organisation
					::Organisation.find(object[:organisation_id])
				end

			end
		end
	end
end
