module Types
  module Objects
    module Consultation
      class Base < BaseObject
        graphql_name "BaseConsultationType"
        field :id, Int, "ID of the consultation", null: false
        field :anonymous_responses, Types::Connections::ConsultationResponse, nil, null: true
        field :created_at, Types::Objects::DateTime, nil, null: false
        field :created_by, Types::Objects::User::Base, nil, null: false
        field :consultation_feedback_email, String, nil, null: true
        field :is_featured, Boolean, nil, null: true
        field :responded_on, Types::Objects::DateTime, nil, null: true do
          def visible?(context)
            super && context[:current_user].present?
          end
        end
        field :consultation_logo, Types::Objects::AttachmentType, nil, null: true do
          argument :resolution, String, required: false, default_value: nil
        end
        field :department, Types::Objects::Department, nil, null: false
        field :consultation_responses_count, Integer, nil, null: false
        field :published_at, Types::Objects::DateTime, nil, null: true
        field :enforce_private_response, Boolean, nil, null: false
        field :response_deadline, Types::Objects::DateTime, "Deadline to submit responses.", null: false
        field :responses, Types::Connections::ConsultationResponse, nil, null: true do
          argument :response_token, String, required: true
          argument :sort, Types::Enums::ConsultationResponseSorts, required: false, default_value: nil
          argument :sort_direction, Types::Enums::SortDirections, required: false, default_value: nil
        end
        field :response_submission_message, String, nil, null: true
        field :review_type, Types::Enums::ConsultationReviewType, nil, null: false
        field :is_satisfaction_rating_optional, Boolean, nil, null: false
        field :show_satisfaction_rating, Boolean, nil, null: true
        field :show_discuss_section, Boolean, nil, null: false
        field :satisfaction_rating_distribution, GraphQL::Types::JSON, nil, null: true
        field :shared_responses, Types::Connections::ConsultationResponse, nil, null: true do
          argument :sort, Types::Enums::ConsultationResponseSorts, required: false, default_value: nil
          argument :sort_direction, Types::Enums::SortDirections, required: false, default_value: nil
        end
        field :status, Types::Enums::ConsultationStatuses, nil, null: false
        field :question_flow, String, nil, null: true
        field :summary, String, nil, null: true
        field :title, String, nil, null: false
        field :hindi_title, String, nil, null: true
        field :odia_title, String, nil, null: true
        field :marathi_title, String, nil, null: true
        field :updated_at, Types::Objects::DateTime, nil, null: false
        field :url, String, nil, null: false
        field :responses_reading_times, Integer, "Reading times of all the responses in this consultation", null: false
        field :reading_time, Integer, "Reading time of this consultation summary", null: false
        field :visibility, Types::Enums::ConsultationVisibilityType, nil, null: false
        field :response_rounds, [Types::Objects::ResponseRoundType], nil, null: true
        field :english_summary, String, nil, null: true
        field :hindi_summary, String, nil, null: true
        field :odia_summary, String, nil, null: true
        field :marathi_summary, String, nil, null: true
        field :summary_hindi, String, nil, null: true
        field :page, String, nil, null: true
        field :consultation_partner_responses, [Types::Objects::ConsultationPartnerResponse::Base], nil, null: true
        field :has_user_filled_response_in_current_response_round, Boolean, null: true

        def has_user_filled_response_in_current_response_round
          return false unless context[:current_user].present?

          object.response_rounds.order(:round_number)
                .last
                &.consultation_responses
                &.where(user: context[:current_user])
                &.exists?
        end

        def responded_on
          nil unless context[:current_user].present?

          object.responded_on(context[:current_user])
        end

        def consultation_logo(resolution:)
          attachment_with_resolution(:consultation_logo, resolution)
        end

        def page
          nil
        end

        def summary_hindi
          nil
        end

        def hindi_title
          object.title_hindi
        end

        def odia_title
          object.title_odia
        end

        def marathi_title
          object.title_marathi
        end

        def english_summary
          return unless object.english_summary.to_s.present?

          object.english_summary_rich_text
        end

        def hindi_summary
          return unless object.hindi_summary.to_s.present?

          object.hindi_summary_rich_text
        end

        def odia_summary
          return unless object.odia_summary.to_s.present?

          object.odia_summary_rich_text
        end

        def marathi_summary
          return unless object.marathi_summary.to_s.present?

          object.marathi_summary_rich_text
        end

        def shared_responses(sort:, sort_direction:)
          object.shared_responses.sort_records(sort, sort_direction)
        end

        def responses(response_token:, sort:, sort_direction:)
          raise Unauthorized if response_token != object.response_token

          object.responses.acceptable_responses.sort_records(sort, sort_direction)
        end

        def consultation_partner_responses
          grouped_responses = object.responses.where.not(organisation_id: nil).group(:organisation_id).count

          grouped_responses.map do |organisation_id, response_count|
            organisation = ::Organisation.find(organisation_id)
            { organisation: organisation, response_count: response_count }
          end
        end

        def consultation_responses_count
          object.responses.count
        end

        def responses_reading_times
          object.shared_responses.sum(:reading_time)
        end

        def response_rounds
          object.response_rounds.order(:created_at)
        end

        def enforce_private_response
          object.private_response?
        end

        def response_deadline
          object.response_deadline&.in_time_zone('Asia/Kolkata')
        end
      end
    end
  end
end
