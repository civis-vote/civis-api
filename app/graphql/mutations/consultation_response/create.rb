module Mutations
  module ConsultationResponse
    class Create < Mutations::BaseMutation
      type Types::Objects::ConsultationResponse::Base, null: false

      argument :consultation_response, Types::Inputs::ConsultationResponse::Create, required: true

      def resolve(consultation_response:)
        user = context[:current_user]
        unless user.present? || submission_allowed?(consultation_response.consultation_id)
          raise Unauthorized, I18n.t('consultation_response.unauthorized')
        end

        response = ::ConsultationResponse.build_for_submission(
          consultation_response.to_h.except(:voice_responses, :clause_feedbacks),
          consultation: ::Consultation.find(consultation_response.consultation_id),
          user: user
        )
        response.submit(
          voice_responses: consultation_response.voice_responses,
          clause_feedbacks: consultation_response.clause_feedbacks
        )
        response.enqueue_voice_transcriptions
        response
      end

      def submission_allowed?(consultation_id)
        return true if (Rails.env.staging? && consultation_id.eql?(::Consultation::SKIP_AUTH_STAGING_ID)) ||
                       (Rails.env.production? && consultation_id.eql?(::Consultation::SKIP_AUTH_PRODUCTION_ID))

        false
      end
    end
  end
end
