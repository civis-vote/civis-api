Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"

  interfaces [
  	Mutations::AuthMutationQueryType,
  	Mutations::MinistryMutationQueryType
  ]

end