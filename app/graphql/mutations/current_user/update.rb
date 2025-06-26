module Mutations
  module CurrentUser
    class Update < Mutations::BaseMutation
      type Types::Objects::User::CurrentUser, null: false

      argument :user, Types::Inputs::CurrentUser::Update, required: true

      def resolve(user:)
        current_user = context[:current_user]
        user_input = user.to_h
        profile_picture = user_input.delete(:profile_picture_file)
        current_user.update! user_input
        if profile_picture.present?
          current_user.save_attachment_with_base64(:profile_picture, profile_picture[:content], profile_picture[:filename])
        end
        current_user
      end

      def self.authorized?(object, context)
        context[:current_user].present?
      end
    end
  end
end
