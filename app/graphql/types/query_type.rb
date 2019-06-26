Types::QueryType = GraphQL::ObjectType.define do
  name "Query"

  interfaces [
  	Queries::CurrentUserQueryType,
  	Queries::LocationQueryType,
  	Queries::MinistryQueryType
  ]

end