module Mutations
  module Auth
    class ForgotPassword < Mutations::BaseMutation
      type Types::Objects::ApiKey, null: false

      argument :email, String, nil, required: true

      def resolve(email:)
        user = User.find_by(email: email)
        if user
          raw_token, encrypted_token = Devise.token_generator.generate(User, :reset_password_token)
          user.reset_password_token = encrypted_token
          user.reset_password_sent_at = Time.now.utc
          user.save
          forgot_password_url = user.forgot_password_url(raw_token)
          ForgotPasswordEmailJob.perform_later(user, forgot_password_url)
          user.find_or_generate_api_key
        else
          raise CivisApi::Exceptions::FailedLogin
        end
      end
    end
  end
end