Types::Objects::ConstantType = GraphQL::ObjectType.define do
  name "ConstantType"

  field :id,                types.Int
  field :constant_type,     types.String
  field :name,              types.String

end
