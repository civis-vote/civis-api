module Mutations
  module Ministry
    class Create < Mutations::BaseMutation
      type Types::Objects::Ministry, null: false

      argument :ministry, Types::Inputs::Ministry::Create, required: true

      def resolve(ministry:)
        created_ministry = ::Ministry.new ministry.to_h
        created_ministry.created_by = Current.user
        created_ministry.save_with_attachments
        return created_ministry
      end

      def self.accessible?(context)
        context[:current_user].present?
      end
    end
  end
end