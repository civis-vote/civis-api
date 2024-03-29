module Mutations
  module Auth
    class ForgotPassword < Mutations::BaseMutation
      type String, null: true

      argument :email, String, nil, required: true

      def resolve(email:)
        user = ::User.find_by(email: email)
        raise CivisApi::Exceptions::FailedLogin unless user
        raw_token, encrypted_token = Devise.token_generator.generate(::User, :reset_password_token)
        user.reset_password_token = encrypted_token
        user.reset_password_sent_at = Time.now.utc
        user.save
        forgot_password_url = user.forgot_password_url(raw_token)
        ForgotPasswordEmailJob.perform_later(user, forgot_password_url)
        user.find_or_generate_api_key
        return "If your account exists, you will receive an email on your registered email address, with the instructions to rephrase the password. If you haven’t received the email, please contact info@civis.vote for support"
      end
    end
  end
end