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

        created_consultation_response = ::ConsultationResponse.new consultation_response.to_h
        created_consultation_response.user = user
        @consultation = ::Consultation.find(consultation_response.consultation_id)
        active_response_round = @consultation.response_rounds.order(:created_at).last
        created_consultation_response.response_round = active_response_round
        if @consultation.private_consultation?
          if @consultation.private_response? && created_consultation_response.visibility == "shared"
            raise GraphQL::ExecutionError, "Private response is enforced, response visibility can't be shared"
          end

          respondent = ::Respondent.find_by(user: user, response_round: active_response_round)
          created_consultation_response.respondent_id = respondent.id if respondent
        end
        if ::ConsultationResponse.exists?(user: user, response_round: active_response_round)
          raise IncompleteEntity, "Response already submitted by User"
        end

        created_consultation_response.save!
        created_consultation_response
      end

      def submission_allowed?(consultation_id)
        return true if (Rails.env.staging? && consultation_id.eql?(475)) || (Rails.env.production? && consultation_id.eql?(1245))

        false
      end
    end
  end
end
