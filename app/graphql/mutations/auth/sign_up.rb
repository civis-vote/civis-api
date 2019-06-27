module Mutations
  module Auth
    class SignUp < Mutations::BaseMutation
      type Types::Objects::ApiKey, null: false

      argument :auth, Types::Inputs::Auth::SignUp, required: true

      def resolve(auth:)
        user = User.new auth.to_h
        user.skip_confirmation_notification!
        user.save!
        return user.live_api_key
      end
    end
  end
end