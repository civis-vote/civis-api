module Mutations
  module Auth
    class ChangePassword < Mutations::BaseMutation
      type Types::Objects::User::CurrentUser, null: false

      argument :user, Types::Inputs::Auth::ChangePassword, required: true

      def resolve(user:)
        current_user = context[:current_user]
        raise CivisApi::Exceptions::IncorrectPassword unless current_user.valid_password?(user[:old_password])
        current_user.update!(password: user[:new_password])
        return current_user
      end

      def self.authorized?(object, context)
        context[:current_user].present?
      end
    end
  end
end