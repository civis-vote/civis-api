module Mutations
  module Auth
    class VerifyOtp < Mutations::BaseMutation
      type Types::Objects::ApiKey, null: false

      argument :auth, Types::Inputs::Auth::VerifyOtp, required: true

      def resolve(auth:)
        user = ::User.find_by(email: auth[:email])
        raise FailedLogin, "You have entered a wrong OTP" unless user&.verify_otp(auth[:otp])

        user.find_or_generate_api_key
        user.live_api_key
      end
    end
  end
end
