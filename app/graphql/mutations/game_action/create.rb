module Mutations
  module Ministry
    class Create < Mutations::BaseMutation
      type Types::Objects::GameAction, null: false

      argument :game_action, Types::Inputs::GameAction::Create, required: true

      def resolve(game_action:)
        current_user = context[:current_user]
        game_action = current_user.game_actions.create! game_action.to_h
        return game_action
      end

      def self.authorized?(object, context)
        context[:current_user].present?
      end
    end
  end
end