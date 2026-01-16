module Queries
  module People
    class List < Queries::BaseQuery
      type Types::Objects::People, null: false

      def resolve
        ::TeamMember.active_only.alphabetical
      end
    end
  end
end
