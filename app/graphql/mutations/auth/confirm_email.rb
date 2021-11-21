module Mutations
  module Auth
    class ConfirmEmail < Mutations::BaseMutation
      type Types::Objects::ApiKey, null: false

      argument :confirmation_token, String, required: true

      def resolve(confirmation_token:)
        user = ::User.find_by(confirmation_token: confirmation_token)
        raise CivisApi::Exceptions::Unauthorized unless user
        user.confirm
        user.find_or_generate_api_key
        user.live_api_key
        return "If you account exists, you will receive an email. If you haven’t received the email, please contact support for further help."
      end
    end
  end
end