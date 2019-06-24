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

GraphQL::Errors.configure(CivisApiSchema) do
  rescue_from ActiveRecord::RecordNotFound do |exception|
    nil
  end

  rescue_from CivisApi::Exceptions::Unauthorized do |exception|
  	GraphQL::ExecutionError.new(exception.message, extensions: {code: :unauthorized, sub_code: :unauthorized})
  end

  rescue_from ActiveRecord::RecordInvalid do |exception|
    GraphQL::ExecutionError.new(exception.record.errors.full_messages.join("\n"), extensions: {code: :unprocessable_entity, sub_code: :record_invalid})
  end

  rescue_from StandardError do |exception|
    GraphQL::ExecutionError.new("Please try to execute the query for this field later")
  end
end