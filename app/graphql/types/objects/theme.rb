module Types
  module Objects
    class Theme < BaseObject
      field :id, Int, nil, null: false
      field :name, String, nil, null: false
      field :cover_photo, Types::Objects::AttachmentType, nil, null: true do
        argument :resolution, String, required: false, default_value: nil
      end

      def cover_photo(resolution:)
        attachment_with_resolution(:cover_photo, resolution)
      end
    end
  end
end
