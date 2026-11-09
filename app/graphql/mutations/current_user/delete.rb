module Mutations
  module CurrentUser
    class Delete < Mutations::BaseMutation
      type Boolean, null: false

      def resolve
        AccountDeletionService.new(context[:current_user]).call
      end

      def self.authorized?(_object, context)
        context[:current_user].present?
      end
    end
  end
end
