GraphQL::Field.accepts_definitions is_public: GraphQL::Define.assign_metadata_key(:is_public)
CivisApiSchema = GraphQL::Schema.define do
  mutation(Types::MutationType)
  query(Types::QueryType)

  # Object Resolution
  resolve_type -> (type, obj, ctx) {
    return obj.class.graphql_type
    raise(NotImplementedError)
  }

end