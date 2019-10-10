module Mutations
  module Auth
    class ResendVerificationEmail < Mutations::BaseMutation
      type Types::Objects::ApiKey, null: false

      argument :email, String, nil, required: true

      def resolve(email:)
        user = User.find_by(email: email)
        if user
          user.send_email_verification
          user.find_or_generate_api_key
        else
          raise CivisApi::Exceptions::FailedLogin, "Email not found"
        end
      end
    end
  end
end