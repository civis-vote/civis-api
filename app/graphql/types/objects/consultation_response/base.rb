module Types
	module Objects
		module ConsultationResponse
			class Base < BaseObject
				graphql_name "BaseConsultationResponseType"
				field :answers, 													GraphQL::Types::JSON, nil, null: true
				field :consultation,											Types::Objects::Consultation::Base, nil, null: false
				field :created_at,												Types::Objects::DateTime, nil, null: false
				field :down_vote_count,										Integer, "Count of users that down-votes this response", null: false
				field :id,																Integer, "ID of the consultation", null: false
				field :points,														Float, "Points earned by submitting this response", null: false
				field :reading_time,											Integer, "Reading time of this response", null: false
				field :response_text,											String, nil, null: false
				field :satisfaction_rating,								Types::Enums::ConsultationResponseSatisfactionRatings, nil, null: false
				field :satisfaction_rating_distribution, 	GraphQL::Types::JSON, nil, null: true
				field :templates_count,										Integer, "Count of responses that used this response as a template", null: false
				field :up_vote_count,											Integer, "Count of users that up-voted this response", null: false
				field :updated_at,												Types::Objects::DateTime, nil, null: false
				field :user,															Types::Objects::User::Base, nil, null: true
				field :visibility,												Types::Enums::ConsultationResponseVisibilities, nil, null: false
				field :voted_as,													Types::Objects::Vote, nil, null: true do 
					def visible?(context)
						super && context[:current_user].present?
					end			
				end

				def voted_as
					object.voted_as(context[:current_user])
				end

				def user
					return object.user if object.shared?
					return object.user if object.user == context[:current_user]
					return nil
				end
			end
		end
	end
end