module Mutations
  module ConsultationResponse
    class Create < Mutations::BaseMutation
      type Types::Objects::ConsultationResponse::Base, null: false

      argument :consultation_response, Types::Inputs::ConsultationResponse::Create, required: true

      def resolve(consultation_response:)
        created_consultation_response = ::ConsultationResponse.new consultation_response.to_h
        created_consultation_response.user = context[:current_user]
        created_consultation_response.save!
        return created_consultation_response
      end

      def self.accessible?(context)
        context[:current_user].present?
      end
    end
  end
end