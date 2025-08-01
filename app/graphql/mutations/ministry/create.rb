module Mutations
  module Ministry
    class Create < Mutations::BaseMutation
      type Types::Objects::Ministry, null: false

      argument :ministry, Types::Inputs::Ministry::Create, required: true

      def resolve(ministry:)
        ministry_input = ministry.to_h
        logo_file = ministry_input.delete(:logo_file)
        created_ministry = ::Ministry.new ministry_input
        created_ministry.created_by = Current.user
        created_ministry.save!
        if logo_file.present?
          created_ministry.save_attachment_with_base64(:logo, logo_file[:content], logo_file[:filename])
        end
        created_ministry
      end

      def self.accessible?(context)
        context[:current_user].present?
      end
    end
  end
end
