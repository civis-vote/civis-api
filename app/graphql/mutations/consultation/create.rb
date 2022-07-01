module Mutations
  module Consultation
    class Create < Mutations::BaseMutation
      type Types::Objects::Consultation::Base, null: false

      argument :consultation, Types::Inputs::Consultation::Create, required: true

      def resolve(consultation:)
        created_consultation = ::Consultation.new consultation.to_h
        created_consultation.created_by = context[:current_user]
        created_consultation.save!
        return created_consultation
      end

      def self.accessible?(context)
        context[:current_user].present?
      end
    end
  end
end