module Mutations
  module Auth
    class Login < Mutations::BaseMutation
      type Boolean, null: false

      argument :auth, Types::Inputs::Auth::Login, required: true

      def resolve(auth:)
        email = auth[:email].to_s.strip.presence
        phone = ::User.normalize_phone(auth[:phone_number])
        raise BadRequest, "Email or phone number is required" if email.blank? && phone.blank?

        identifier = email.present? ? { email: } : { phone_number: phone }
        user = find_or_create_user(identifier)

        otp_request = user.create_otp_request(delivery_channel: identifier.key?(:email) ? :email : :phone)
        raise BadRequest, otp_request.errors.full_messages.to_sentence if otp_request.errors.any?

        true
      end

      private

      def find_or_create_user(identifier)
        ::User.find_or_create_by!(identifier)
      rescue ActiveRecord::RecordNotUnique
        ::User.find_or_create_by!(identifier)
      end
    end
  end
end
