module Mutations
  module Auth
    class ConfirmEmail < Mutations::BaseMutation
      type Types::Objects::ApiKey, null: false

      argument :confirmation_token, String, required: true

      def resolve(confirmation_token:)
        user = ::User.find_by(confirmation_token: confirmation_token)
        raise Unauthorized if user.blank?

        user.confirm
        user.find_or_generate_api_key
        user.live_api_key
      end
    end
  end
end