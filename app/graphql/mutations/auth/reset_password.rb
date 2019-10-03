module Mutations
  module Auth
    class ResetPassword < Mutations::BaseMutation
      type Types::Objects::ApiKey, null: false

      argument :auth, Types::Inputs::Auth::ResetPassword, required: true

      def resolve(auth:)
        token = Devise.token_generator.digest(User,:reset_password_token, auth[:reset_password_token])
        user = User.find_by(reset_password_token: token)
        if user
          user.reset_password_sent_at = nil
          user.reset_password_token = nil
          user.password = auth[:password]
          user.save
          user.find_or_generate_api_key
          user.live_api_key
        else
          raise CivisApi::Exceptions::Unauthorized
        end
      end
    end
  end
end 