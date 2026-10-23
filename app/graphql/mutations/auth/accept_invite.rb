module Mutations
  module Auth
    class AcceptInvite < Mutations::BaseMutation
      type Types::Objects::ApiKey, null: false

      argument :auth, Types::Inputs::Auth::AcceptInvite, required: true

      def resolve(auth:)
        user = ::User.find_by_invitation_token(auth[:invitation_token], true)
        raise Unauthorized, "Invalid or expired invitation token" unless user.present?

        consultation = ::Consultation.find(auth[:consultation_id])
        raise Unauthorized, "Invitation expired" if consultation.response_deadline.to_date < Date.today

        attrs = auth.to_h.except!(:consultation_id)
        attrs[:password] = "#{SecureRandom.hex(20)}@a1" if attrs[:password].blank?
        user = ::User.accept_invitation!(attrs)
        raise Unauthorized, "Unable to accept invitation" unless user.invitation_accepted?

        user.find_or_generate_api_key
        user.live_api_key
      end
    end
  end
end
