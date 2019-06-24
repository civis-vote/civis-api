Types::QueryType = GraphQL::ObjectType.define do
  name "Query"

  interfaces [
  	Queries::LocationQueryType,
  	Queries::CurrentUserQueryType
  ]

end