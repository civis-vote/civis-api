module Queries
  module TeamMember
    class List < Queries::BaseQuery
      argument :page, Int, required: false, default_value: 1
      argument :per_page, Int, required: false, default_value: 20
      argument :sort, Types::Enums::TeamMemberSorts, required: false, default_value: nil
      argument :sort_direction, Types::Enums::SortDirections, required: false, default_value: nil
      argument :member_type_filter, Types::Enums::TeamMemberTypes, required: false

      type Types::Objects::TeamMember::List, null: false

      def resolve(page:, per_page:, sort:, sort_direction:, member_type_filter:)
        ::TeamMember
          .active_only
          .member_type_filter(member_type_filter)
          .sort_records(sort, sort_direction)
          .list(per_page, page)
      end
    end
  end
end