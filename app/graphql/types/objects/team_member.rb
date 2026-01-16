module Types
  module Objects
    class TeamMember < BaseObject
      field :id, ID, null: false
      field :name, String, null: false
      field :designation, String, null: false
      field :linkedin_url, String, null: true

      field :profile_picture, Types::Objects::AttachmentType, null: true do
        argument :resolution, String, required: false, default_value: nil
      end

      def profile_picture(resolution:)
        attachment_with_resolution(:profile_picture, resolution)
      end
    end
  end
end
