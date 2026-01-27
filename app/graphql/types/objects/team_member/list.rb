module Types
  module Objects
    module TeamMember
      class List < Types::BaseObject
        graphql_name "TeamMemberList"

        field :data, [Types::Objects::TeamMember::Base], null: false
        field :paging, Types::Objects::Paging, null: false
      end
    end
  end
end