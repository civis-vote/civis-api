Types::Objects::ApiKeyType = GraphQL::ObjectType.define do
  name "ApiKeyType"

  field :access_token,        types.String
  # field :expires_at,          Types::Objects::DateTimeType
end