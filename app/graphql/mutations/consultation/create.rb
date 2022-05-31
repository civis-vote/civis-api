module Mutations
  module Consultation
    class Create < Mutations::BaseMutation
      type Types::Objects::Consultation::Base, null: false

      argument :consultation, Types::Inputs::Consultation::Create, required: true

      def resolve(consultation:)
        created_consultation = ::Consultation.new consultation.to_h
        created_consultation.created_by = context[:current_user]
        created_consultation.save!
        user_notifications_new = ::UserNotification.new 
        user_notifications_new.create_notification('Notifications consultation', created_consultation.created_by_id) # store consultation id 
        return created_consultation
      end

      def self.accessible?(context)
        context[:current_user].present?
      end
    end
  end
end