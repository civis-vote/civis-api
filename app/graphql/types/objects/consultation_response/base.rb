module Types
	module Objects
		module ConsultationResponse
			class Base < BaseObject
				graphql_name "BaseConsultationResponseType"
				field :id,									Int, "ID of the consultation", null: false
				field :created_at,					Types::Objects::DateTime, nil, null: false
				field :updated_at,					Types::Objects::DateTime, nil, null: false
				field :user,								Types::Objects::User::Base, nil, null: false
				field :consultation,				Types::Objects::Consultation::Base, nil, null: false
				field :satisfaction_rating,	Types::Enums::ConsultationResponseSatisfactionRatings, nil, null: false
				field :response_text,				String, nil, null: false
				field :visibility,					Types::Enums::ConsultationResponseVisibilities, nil, null: false
			end
		end
	end
end