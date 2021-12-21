module Types
	module Objects
		module Consultation
			class Base < BaseObject
				graphql_name "BaseConsultationType"
				field :id,																Int, "ID of the consultation", null: false
				field :anonymous_responses,								Types::Connections::ConsultationResponse, nil, null: true
				field :created_at,												Types::Objects::DateTime, nil, null: false
				field :created_by,												Types::Objects::User::Base, nil, null: false
				field	:consultation_feedback_email,				String, nil, null: true
				field	:summary_hindi,											Types::Objects::CmPageBuilderType, null: true
				field :is_featured,												Boolean, nil, null: true
				field :responded_on,											Types::Objects::DateTime, nil, null: true do 
					def resolve(object, context)
						object.responded_on(context[:current_user])
					end

					def visible?(context)
						super && context[:current_user].present?
					end
				end
				field :ministry,													Types::Objects::Ministry, nil, null: false
				field :consultation_responses_count,			Integer,nil, null: false
				field :page,															Types::Objects::CmPageBuilderType, null: true
				field :published_at,											Types::Objects::DateTime, nil, null: true
				field :enforce_private_response,					Boolean, nil, null: false
				field :response_deadline, 								Types::Objects::DateTime, "Deadline to submit responses.", null: false
				field :responses,													Types::Connections::ConsultationResponse, nil, null: true do 
					argument :response_token,								String, required: true
					argument :sort,													Types::Enums::ConsultationResponseSorts, 	required: false, default_value: nil
					argument :sort_direction,								Types::Enums::SortDirections, 						required: false, default_value: nil
				end
				field :response_submission_message,				String, nil, null: true
				field :review_type,												Types::Enums::ConsultationReviewType, nil, null: false
				field :satisfaction_rating_distribution, 	GraphQL::Types::JSON, nil, null: true
				field :shared_responses,									Types::Connections::ConsultationResponse, nil, null: true do 
					argument :sort,													Types::Enums::ConsultationResponseSorts, 	required: false, default_value: nil
					argument :sort_direction,								Types::Enums::SortDirections, 						required: false, default_value: nil
				end
				field :status,														Types::Enums::ConsultationStatuses, nil, null: false
				field :summary,														String, nil, null: true
				field :title,															String, nil, null: false
				field :updated_at,												Types::Objects::DateTime, nil, null: false
				field :url,																String, nil, null: false
				field :responses_reading_times,						Integer, "Reading times of all the responses in this consultation", null: false
				field :reading_time,											Integer, "Reading time of this consultation summary", null: false
				field :visibility,												Types::Enums::ConsultationVisibilityType, nil, null: false
				field :response_rounds,										[Types::Objects::ResponseRoundType], nil, null: true
				
				def shared_responses(sort:, sort_direction:)
					object.shared_responses.sort_records(sort, sort_direction)
				end

				def responses(response_token:, sort:, sort_direction:)
					raise CivisApi::Exceptions::Unauthorized if response_token != object.response_token
					return object.responses.acceptable_responses.sort_records(sort, sort_direction)
				end

				def responses_reading_times
					object.shared_responses.sum(:reading_time)
				end

				def summary_hindi
					return nil unless object.consultation_hindi_summary.present?
					object.consultation_hindi_summary.page
				end

				def response_rounds
					object.response_rounds.order(:created_at)
				end

				def enforce_private_response
					object.private_response?
				end
			end
		end
	end
end
