module Types
	module Objects
		module ConsultationPartnerResponse
			class Base < BaseObject
				graphql_name "ConsultationPartnerResponseType"
				field :organisation, 														Types::Objects::Organisation::Base, nil, null: false
				field :response_count, 												Integer, nil, null: false
			end
		end
	end
end
