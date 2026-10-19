module Queries
  module Constant
    class List < Queries::BaseQuery
      description "Get a list of constants"
      argument :constant_type, Types::Enums::ConstantTypes, required: false, default_value: nil
      argument :page, Int, required: false, default_value: 1
      argument :per_page, Int, required: false, default_value: 20
      argument :sort, Types::Enums::ConstantSort, required: false, default_value: nil
      argument :sort_direction, Types::Enums::SortDirections, required: false, default_value: nil

      type Types::Objects::ConstantList, null: true

      def resolve(constant_type:, per_page:, page:, sort:, sort_direction:)
        ::Constant.constant_type_filter(constant_type).sort_records(sort, sort_direction).list(per_page, page)
      end
    end
  end
end
