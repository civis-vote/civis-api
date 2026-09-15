module Types
  module Objects
    class ShowcaseSlide < BaseObject
      graphql_name "ShowcaseSlide"
      description "A showcase slide for the Home Page"

      field :id, Int, "ID of the showcase slide", null: false
      field :title, String, "Title of the slide", null: false
      field :description, String, "Summary/description of the slide", null: true
      field :image, Types::Objects::AttachmentType, "Image/media for the slide", null: true do
        argument :resolution, String, required: false, default_value: nil
      end
      field :cta_label, String, "Label for the call-to-action button", null: false
      field :cta_url, String, "URL for the call-to-action button", null: false
      field :video_url, String, "Video URL for the slide", null: true
      field :status, Types::Enums::ShowcaseSlideStatuses, "Status of the slide", null: false
      field :position, Int, "Display order of the slide (ascending)", null: true
      field :published_at, Types::Objects::DateTime, "When the slide was published", null: true

      def description
        object.description.to_plain_text
      end

      def image(resolution:)
        attachment_with_resolution(:image, resolution)
      end
    end
  end
end
