class GraphqlController < ApplicationController
  before_action :authenticate!, unless: :public_query

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    Current.user = current_user
    Current.ip_address = request.ip
    context = {
      # Query context goes here, for example:
      # current_user: current_user,
    }
    result = CivisApiSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue => e
    raise e unless Rails.env.development?
    handle_error_in_development e
  end

  def authenticate!
    # TODO move the error into a library
    render json: {error: 'Unauthorized request'}, status: 401 unless current_user
  end

  private

  def current_user
    # find token. Check if valid.
    if request.headers['Authorization']
      api_key = ApiKey.verify(request.headers['Authorization'])
      return false unless api_key.present?
      @current_user = api_key.user
      @current_user.update_last_login unless @current_user.was_active_in_last_six_hours?
      @current_user
    else
      false
    end
  end

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { error: { message: e.message, backtrace: e.backtrace }, data: {} }, status: 500
  end

  def public_query
    parsed_query = GraphQL::Query.new CivisApiSchema, params[:query]
    if parsed_query.selected_operation.present?
      operation = parsed_query.selected_operation.selections.first.name
      return true if operation == '__schema'
      field = CivisApiSchema.query.get_field(operation) || CivisApiSchema.mutation.get_field(operation)
      return true if field && field.metadata[:is_public] == true
      false
    else
      raise ArgumentError, "Invalid input or query syntax or no selections made on returning objects."
    end
  end
end