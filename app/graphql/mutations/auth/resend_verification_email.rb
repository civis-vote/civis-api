module Mutations
  module Auth
    class ResendVerificationEmail < Mutations::BaseMutation
      type Boolean, null: false

      argument :email, String, nil, required: true

      def resolve(email:)
        user = ::User.find_by(email: email)
        if user
          user.send_email_verification
          return true
        else
          raise CivisApi::Exceptions::FailedLogin, "Email not found"
        end
      end
    end
  end
end