module Mutations
  module Auth
    class ResendVerificationEmail < Mutations::BaseMutation
      type Boolean, null: false

      argument :email, String, nil, required: true

      def resolve(email:)
        user = ::User.find_by(email: email)
        raise FailedLogin, "Email not found" unless user

        user.send_email_verification
        true
      end
    end
  end
end
