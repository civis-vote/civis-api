module Types
  module Objects
    module TeamMember
      class Base < Types::BaseObject
        graphql_name "TeamMemberBase"

        field :id, ID, null: false
        field :name, String, null: false
        field :designation, String, null: false
        field :linkedin_url, String, null: true
        field :member_type, String, null: false
        field :status, String, null: false

        field :profile_picture, Types::Objects::AttachmentType, null: true do
          argument :resolution, String, required: false
        end

        def profile_picture(resolution: nil)
          attachment_with_resolution(:profile_picture, resolution)
        end
      end
    end
  end
end