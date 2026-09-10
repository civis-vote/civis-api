module Queries
  module Consultation
    class HomePageShowcaseSlides < Queries::BaseQuery
      description "Get showcase slides for the Home Page, backed by published consultations"

      argument :status, Types::Enums::ConsultationStatuses, required: false, default_value: "published"
      argument :limit, Int, required: false, default_value: 20

      type [Types::Objects::ShowcaseSlide], null: false

      def resolve(status:, limit:)
        ::Consultation.public_consultation
                      .status_filter(status)
                      .where.not(response_deadline: nil)
                      .order(response_deadline: :asc)
                      .limit(limit)
      end
    end
  end
end
