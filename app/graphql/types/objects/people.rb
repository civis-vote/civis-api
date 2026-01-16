module Types
  module Objects
    class People < BaseObject
      field :team, [Types::Objects::TeamMember], null: false
      field :advisory, [Types::Objects::TeamMember], null: false
    end
  end
end
