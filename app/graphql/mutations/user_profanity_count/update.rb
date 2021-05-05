module Mutations
  module UserProfanityCount
    class Update < Mutations::BaseMutation
      type Types::Objects::UserProfanityCount::ProfanityCount, null: false

      argument :profanity_count, Types::Inputs::UserProfanityCount::Update, required: true

      def resolve(profanity_count:)
        current_user_id = context[:current_user_id]
        current_user_id.update_attributes! profanity_count.to_h
        return current_user_id
      end

      def self.authorized?(object, context)
        context[:current_user_id].present?
      end
    end
  end
end