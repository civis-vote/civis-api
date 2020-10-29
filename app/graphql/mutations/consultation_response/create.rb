module Mutations
  module ConsultationResponse
    class Create < Mutations::BaseMutation
      type Types::Objects::ConsultationResponse::Base, null: false

      argument :consultation_response, Types::Inputs::ConsultationResponse::Create, required: true

      def resolve(consultation_response:)
        created_consultation_response = ::ConsultationResponse.new consultation_response.to_h
        created_consultation_response.user = context[:current_user]
        @consultation = ::Consultation.find(consultation_response.consultation_id)
        active_response_round = @consultation.response_rounds.order(:created_at).last
        created_consultation_response.response_round = active_response_round
        if @consultation.private_consultation?
          raise GraphQL::ExecutionError, "Private response is enforced, response visibility can't be shared" if (@consultation.private_response? && created_consultation_response.visibility == "shared")
          respondent = ::Respondent.find_by(user: context[:current_user], response_round: active_response_round)
          created_consultation_response.respondent_id = respondent.id if respondent
        end
        created_consultation_response.save!
        return created_consultation_response
      end

      def self.accessible?(context)
        context[:current_user].present?
      end
    end
  end
end