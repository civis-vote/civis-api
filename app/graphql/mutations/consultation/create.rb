module Mutations
  module Consultation
    class Create < Mutations::BaseMutation
      type Types::Objects::Consultation::Base, null: false

      argument :consultation, Types::Inputs::Consultation::Create, required: true

      def resolve(consultation:)
        attributes = consultation.to_h
        theme_ids = attributes.delete(:theme_ids)
        created_consultation = ::Consultation.new attributes
        created_consultation.created_by = context[:current_user]
        created_consultation.save!
        created_consultation.theme_ids = theme_ids if theme_ids.present?
        return created_consultation
      end

      def self.accessible?(context)
        context[:current_user].present?
      end
    end
  end
end