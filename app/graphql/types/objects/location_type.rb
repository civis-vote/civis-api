Types::Objects::LocationType = GraphQL::ObjectType.define do
  name "LocationType"

  field :id,                types.Int
  field :location_type,		types.String
  field :name,              types.String
  field :parent,			Types::Objects::LocationType
end
