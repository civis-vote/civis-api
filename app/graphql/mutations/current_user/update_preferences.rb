module Mutations
  module CurrentUser
    class UpdatePreferences < Mutations::BaseMutation
      type Types::Objects::User::CurrentUser, null: false

      argument :user, Types::Inputs::CurrentUser::UpdatePreferences, required: true

      def resolve(user:)
        current_user = context[:current_user]
        user_input = user.to_h

        ActiveRecord::Base.transaction do
          current_user.preferred_theme_ids = ::Theme.where(id: user_input[:theme_ids]).ids unless user_input[:theme_ids].nil?

          unless user_input[:area_of_impact_ids].nil?
            sync_area_of_impacts(current_user, ::Constant.area_of_impact.where(id: user_input[:area_of_impact_ids]).ids)
          end
        end

        current_user
      end

      def self.authorized?(_, context)
        context[:current_user].present?
      end

      private

      def sync_area_of_impacts(current_user, constant_ids)
        existing_ids = current_user.area_of_impact_ids
        current_user.constant_maps.where(constant_id: existing_ids - constant_ids).delete_all
        (constant_ids - existing_ids).each do |constant_id|
          current_user.constant_maps.create!(constant_id:)
        end
      end
    end
  end
end
