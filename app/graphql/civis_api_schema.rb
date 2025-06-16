class CivisApiSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  def self.resolve_type(_abstract_type, _obj, _ctx)
    raise(GraphQL::RequiredImplementationMissingError)
  end

  def self.id_from_object(object, type_definition, _query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
  end

  # Given a string UUID, find the object
  def self.object_from_id(encoded_id_with_hint, _query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    # Split off the type hint
  end

  rescue_from ActiveRecord::RecordNotFound do |err, _obj, _args, _ctx, field|
    GraphQL::ExecutionError.new("#{field.type.unwrap.graphql_name} not found",
                                extensions: { code: :unprocessable_entity, sub_code: :record_invalid,
                                              message: err.message })
  end

  rescue_from ActiveRecord::RecordInvalid do |err, _obj, _args, _ctx, _field|
    GraphQL::ExecutionError.new(err.message,
                                extensions: { code: :unprocessable_entity, sub_code: :record_invalid,
                                              message: err.message })
  end

  rescue_from BaseException do |err, _obj, _args, _ctx, _field|
    GraphQL::ExecutionError.new(err.message,
                                extensions: { code: err.code, sub_code: err.sub_code, message: err.message })
  end

  rescue_from FailedLogin do |err, _obj, _args, _ctx, _field|
    GraphQL::ExecutionError.new(err.message,
                                extensions: { code: err.code, sub_code: err.sub_code, message: err.message })
  end

  rescue_from Unauthorized do |err, _obj, _args, _ctx, _field|
    GraphQL::ExecutionError.new(err.message,
                                extensions: { code: err.code, sub_code: err.sub_code, message: err.message })
  end

  rescue_from IncompleteEntity do |err, _obj, _args, _ctx, _field|
    GraphQL::ExecutionError.new(err.message,
                                extensions: { code: err.code, sub_code: err.sub_code, message: err.message })
  end

  def self.unauthorized_object(error)
    raise Unauthorized, I18n.t("graphql.unauthorized", error_type: error.type.graphql_name)
  end

  unless Rails.env.development?
    rescue_from StandardError do |err, _obj, _args, _ctx, _field|
      GraphQL::ExecutionError.new(err.message,
                                  extensions: { code: :internal_server_error })
    end
  end
end
