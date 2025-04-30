class CivisApiSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  def self.unauthorized_object(error)
    raise CivisApi::Exceptions::Unauthorized.new "Permissions configuration do not allow the object you requested, of type #{error.type.graphql_name}"
  end
end

GraphQL::Relay::ConnectionType.bidirectional_pagination = true
GraphQL::Errors.configure(CivisApiSchema) do
  rescue_from ActiveRecord::RecordNotFound do |exception|
    nil
  end

  rescue_from CivisApi::Exceptions::Unauthorized do |exception|
  	GraphQL::ExecutionError.new(exception.message, extensions: {code: :unauthorized, sub_code: :unauthorized})
  end

  rescue_from CivisApi::Exceptions::FailedLogin do |exception|
  	GraphQL::ExecutionError.new(exception.message, extensions: {code: :unauthorized, sub_code: :unauthorized})
  end

  rescue_from ActiveRecord::RecordInvalid do |exception|
    GraphQL::ExecutionError.new(exception.record.errors.full_messages.join("\n"), extensions: {code: :unprocessable_entity, sub_code: :record_invalid})
  end

  rescue_from CivisApi::Exceptions::IncorrectPassword do |exception|
    GraphQL::ExecutionError.new(exception.message, extensions: {code: :unauthorized, sub_code: :unauthorized})
  end
  
  unless Rails.env.development?
	  rescue_from StandardError do |exception|
      error = Airbrake.notify_sync(exception)
	    GraphQL::ExecutionError.new("Please try to execute the query for this field later", extensions: {code: :internal_server_error, event_id: error['id']})
	  end
	end
end
