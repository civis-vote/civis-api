module Mutations
  module Auth
    class Login < Mutations::BaseMutation
      type Boolean, null: false

      argument :auth, Types::Inputs::Auth::Login, required: true

      def resolve(auth:)
        email = auth[:email].to_s.strip.presence
        phone = ::User.normalize_phone(auth[:phone_number])
        raise BadRequest, "Email or phone number is required" if email.blank? && phone.blank?

        user = if email.present?
                 ::User.find_or_create_by!(email: email)
               else
                 ::User.find_for_login(phone_number: phone) || ::User.create!(phone_number: phone)
               end

        otp_request = user.create_otp_request(delivery_channel: email.present? ? :email : :phone)
        raise BadRequest, otp_request.errors.full_messages.to_sentence if otp_request.errors.any?

        true
      end
    end
  end
end
