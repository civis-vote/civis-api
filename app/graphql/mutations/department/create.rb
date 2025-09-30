module Mutations
  module Department
    class Create < Mutations::BaseMutation
      type Types::Objects::Department, null: false

      argument :ministry, Types::Inputs::Department::Create, required: true

      def resolve(ministry:)
        ministry_input = ministry.to_h
        logo_file = ministry_input.delete(:logo_file)
        created_ministry = ::Department.new ministry_input
        created_ministry.created_by = Current.user
        created_ministry.save!
        created_ministry.save_attachment_with_base64(:logo, logo_file[:content], logo_file[:filename]) if logo_file.present?
        created_ministry
      end

      def self.accessible?(context)
        context[:current_user].present?
      end
    end
  end
end
