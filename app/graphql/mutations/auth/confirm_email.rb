module Mutations
  module Auth
    class ConfirmEmail < Mutations::BaseMutation
      type String, null: true

      argument :confirmation_token, String, required: true

      def resolve(confirmation_token:)
        user = ::User.find_by(confirmation_token: confirmation_token)
        raise CivisApi::Exceptions::Unauthorized unless user
        user.confirm
        user.find_or_generate_api_key
        user.live_api_key
        return "If your account exists, you will receive an email on your registered email address. If you haven’t received the email, please contact info@civis.vote for support"
      end
    end
  end
end