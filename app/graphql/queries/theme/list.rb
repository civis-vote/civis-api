module Queries
  module Theme
    class List < Queries::BaseQuery
      description "Get a list of categories"
      argument :page, Int, required: false, default_value: 1
      argument :per_page, Int, required: false, default_value: 20
      argument :sort, Types::Enums::ThemeSort, required: false, default_value: nil
      argument :sort_direction, Types::Enums::SortDirections, required: false, default_value: nil

      type Types::Objects::ThemeList, null: true

      def resolve(per_page:, page:, sort:, sort_direction:)
        ::Theme.sort_records(sort, sort_direction).list(per_page, page)
      end
    end
  end
end
