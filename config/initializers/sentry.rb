Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn)
  config.enabled_environments = %w[production staging]
  config.excluded_exceptions += ['ActionController::RoutingError']
end
