module Mutations
  module Auth
    class VerifyOtp < Mutations::BaseMutation
      type Types::Objects::ApiKey, null: false

      argument :auth, Types::Inputs::Auth::VerifyOtp, required: true

      def resolve(auth:)
        user = ::User.find_by(email: auth[:email])
        raise CivisApi::Exceptions::IncorrectOtp unless user && user.verify_otp(auth[:otp])
        
        user.find_or_generate_api_key
        user.live_api_key
      end
    end
  end
end