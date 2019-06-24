Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"

  interfaces [
  	Mutations::AuthMutationQueryType
  ]

end