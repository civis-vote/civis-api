module Mutations
  module ConsultationResponse
    class Create < Mutations::BaseMutation
      type Types::Objects::ConsultationResponse::Base, null: false

      argument :consultation_response, Types::Inputs::ConsultationResponse::Create, required: true

      def resolve(consultation_response:)
        created_consultation_response = ::ConsultationResponse.new consultation_response.to_h
        created_consultation_response.user = context[:current_user]
        @consultation = ::Consultation.find(consultation_response.consultation_id)
        if @consultation.private_consultation?
          respondent = ::Respondent.find_by(user_id: context[:current_user].id, response_round_id: @consultation.response_rounds.order(:created_at).last.id)
          created_consultation_response.respondent_id = respondent.id
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