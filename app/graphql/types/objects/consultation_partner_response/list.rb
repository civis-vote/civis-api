module Types
	module Objects
		module ConsultationResponse
			class List < BaseObject
				graphql_name "ListConsultationResponseType"
				field :data,								[Types::Objects::ConsultationResponse::Base], nil, null: true
				field :paging,							Types::Objects::Paging,               				nil, null: false
			end
		end
	end
end