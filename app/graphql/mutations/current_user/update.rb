module Mutations
  module CurrentUser
    class Update < Mutations::BaseMutation
      type Types::Objects::User::CurrentUser, null: false

      argument :user, Types::Inputs::CurrentUser::Update, required: true

      def resolve(user:)
        current_user = context[:current_user]
        user_input = user.to_h
        profile_picture = user_input.delete(:profile_picture_file)
        theme_ids = user_input.delete(:theme_ids)
        area_of_impact_ids = user_input.delete(:area_of_impact_ids)

        ActiveRecord::Base.transaction do
          current_user.update! user_input
          current_user.preferred_theme_ids = ::Theme.where(id: theme_ids).ids unless theme_ids.nil?
          sync_area_of_impacts(current_user, ::Constant.area_of_impact.where(id: area_of_impact_ids).ids) unless area_of_impact_ids.nil?
        end

        current_user.save_attachment_with_base64(:profile_picture, profile_picture[:content], profile_picture[:filename]) if profile_picture.present?
        current_user
      end

      def self.authorized?(_, context)
        context[:current_user].present?
      end

      private

      def sync_area_of_impacts(current_user, constant_ids)
        existing_ids = current_user.area_of_impact_ids
        current_user.user_preferences.where(preferable_type: 'Constant', preferable_id: existing_ids - constant_ids).delete_all
        (constant_ids - existing_ids).each do |constant_id|
          current_user.user_preferences.create!(preferable_type: 'Constant', preferable_id: constant_id)
        end
      end
    end
  end
end
