module Types
  module Objects
    module TeamMember
      class List < Types::BaseObject
        graphql_name "TeamMemberList"

        field :records, [Types::Objects::TeamMember::Base], null: false
      end
    end
  end
end
