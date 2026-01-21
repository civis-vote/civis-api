module Queries
  module TeamMember
    class List < Queries::BaseQuery
      argument :member_type, String, required: false
      type Types::Objects::TeamMember::List, null: false

      def resolve(member_type: nil)
        ::TeamMember.list(member_type: member_type)
      end
    end
  end
end
