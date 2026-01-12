module Queries
  module People
    class List < Queries::BaseQuery
      type Types::Objects::People, null: false

      def resolve
        members = ::TeamMember
                    .where(active: true)
                    .alphabetical

        {
          team: members.team,
          advisory: members.advisory
        }
      end
    end
  end
end
