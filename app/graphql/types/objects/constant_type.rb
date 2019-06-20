Types::Objects::ConstantType = GraphQL::ObjectType.define do
  name "ConstantType"

  field :id,                types.Int
  field :name,              types.String
  field :constant_type,     types.String

end
