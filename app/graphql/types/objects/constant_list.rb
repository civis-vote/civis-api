module Types
  module Objects
    class ConstantList < BaseObject
      graphql_name "ListConstantType"

      field :data, [Types::Objects::Constant], nil, null: true
      field :paging, Types::Objects::Paging, nil, null: false
    end
  end
end
