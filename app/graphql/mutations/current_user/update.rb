module Mutations
  module CurrentUser
    class Update < Mutations::BaseMutation
      type Types::Objects::User::CurrentUser, null: false

      argument :user, Types::Inputs::CurrentUser::Update, required: true

      def resolve(user:)
        current_user = context[:current_user]
        current_user.update_attributes! user.to_h
        return current_user
      end

      def self.authorized?(object, context)
        context[:current_user].present?
      end
    end
  end
end