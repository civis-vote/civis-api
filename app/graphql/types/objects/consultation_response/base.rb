module Types
	module Objects
		module ConsultationResponse
			class Base < BaseObject
				graphql_name "BaseConsultationResponseType"
				field :id,																Integer, "ID of the consultation", null: false
				field :created_at,												Types::Objects::DateTime, nil, null: false
				field :down_vote_count,										Integer, "Count of users that down-votes this response", null: false
				field :updated_at,												Types::Objects::DateTime, nil, null: false
				field :user,															Types::Objects::User::Base, nil, null: false
				field :consultation,											Types::Objects::Consultation::Base, nil, null: false
				field :points,														Float, "Points earned by submitting this response", null: false
				field :satisfaction_rating,								Types::Enums::ConsultationResponseSatisfactionRatings, nil, null: false
				field :satisfaction_rating_distribution, 	GraphQL::Types::JSON, nil, null: true
				field :response_text,											String, nil, null: false
				field :templates_count,										Integer, "Count of responses that used this response as a template", null: false
				field :up_vote_count,											Integer, "Count of users that up-voted this response", null: false
				field :visibility,												Types::Enums::ConsultationResponseVisibilities, nil, null: false
			end
		end
	end
end