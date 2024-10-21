module Types
	module Objects
		module ConsultationPartnerResponse
			class List < BaseObject
				graphql_name "ListConsultationPartnerResponseType"
				field :data,								[Types::Objects::ConsultationPartnerResponse::Base], nil, null: true
				field :paging,							Types::Objects::Paging,               				nil, null: false
			end
		end
	end
end