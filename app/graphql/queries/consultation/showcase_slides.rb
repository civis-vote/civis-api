module Queries
  module Consultation
    class ShowcaseSlides < Queries::BaseQuery
      description "Get published showcase slides"

      argument :limit, Int, required: false, default_value: 20

      type [Types::Objects::ShowcaseSlide], null: false

      def resolve(limit:)
        ::ShowcaseSlide.where(status: :published)
                       .ordered_by_position
                       .limit(limit)
      end
    end
  end
end
