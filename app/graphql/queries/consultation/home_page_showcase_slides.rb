module Queries
  module Consultation
    class HomePageShowcaseSlides < Queries::BaseQuery
      description "Get showcase slides for the Home Page"

      argument :status, Types::Enums::ShowcaseSlideStatuses, required: false, default_value: "published"
      argument :limit, Int, required: false, default_value: 20

      type [Types::Objects::ShowcaseSlide], null: false

      def resolve(status:, limit:)
        ::ShowcaseSlide.status_filter(status)
                       .ordered_by_position
                       .limit(limit)
      end
    end
  end
end
