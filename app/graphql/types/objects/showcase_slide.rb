module Types
  module Objects
    class ShowcaseSlide < BaseObject
      graphql_name "ShowcaseSlide"
      description "A showcase slide for the Home Page, backed by a Consultation"

      field :id, Int, "ID of the showcase slide", null: false
      field :title, String, "Title of the slide", null: false
      field :description, String, "Summary/description of the slide", null: true
      field :image, Types::Objects::AttachmentType, "Image/media for the slide", null: true do
        argument :resolution, String, required: false, default_value: nil
      end
      field :cta, Types::Objects::ShowcaseSlideCta, "Call-to-action for the slide", null: true
      field :status, Types::Enums::ConsultationStatuses, "Status of the slide", null: false
      field :response_deadline, Types::Objects::DateTime, "Response deadline used for ordering", null: true
      field :published_at, Types::Objects::DateTime, "When the slide was published", null: true

      def title
        object.title
      end

      def description
        object.english_summary_text
      end

      def image(resolution:)
        attachment_with_resolution(:consultation_logo, resolution)
      end

      def cta
        return nil unless object.url.present?

        { label: object.cta_label, url: object.url }
      end

      def status
        object.status
      end

      def response_deadline
        object.response_deadline&.in_time_zone('Asia/Kolkata')
      end

      def published_at
        object.published_at
      end
    end
  end
end
