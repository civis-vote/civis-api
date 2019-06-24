Types::Objects::User::CurrentUserType = GraphQL::ObjectType.define do
  name "CurrentUserType"

  field :id,        types.Int
end