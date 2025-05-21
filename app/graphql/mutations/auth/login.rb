module Mutations
  module Auth
    class Login < Mutations::BaseMutation
      type Types::Objects::ApiKey, null: false

      argument :auth, Types::Inputs::Auth::Login, required: true

      def resolve(auth:)
        user = ::User.find_or_create_by!(email: auth[:email])

        user.create_otp_request
        true
      end
    end
  end
end