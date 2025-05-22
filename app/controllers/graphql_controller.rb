class GraphqlController < ApplicationController
  before_action :authenticate!

  rescue_from Unauthorized do |e|
    render json: { error: 'Unauthorized', message: e.message }, status: :unauthorized
  end

  rescue_from TokenExpired do |e|
    render json: { error: 'TokenExpired', message: e.message }, status: :unauthorized
  end

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    Current.user = current_user
    Current.ip_address = request.ip
    context = {
      current_user: current_user,
    }
    result = CivisApiSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue => e
    raise e unless Rails.env.development?
    handle_error_in_development e
  end

  def authenticate!
    return current_user unless current_user  
    return nil
  end

  private

  def current_user
    # find token. Check if valid.
    if request.headers["Authorization"]
      api_key = ApiKey.verify(request.headers["Authorization"])
      return false unless api_key.present?
      @current_user = api_key.user
      @current_user.update_last_activity unless @current_user.was_active_today?
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
end