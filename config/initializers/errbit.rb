Airbrake.configure do |config|
  config.host = 'https://672pl.hatchboxapp.com'
  config.project_id = 1
  config.project_key = Rails.application.credentials.dig(:airbrake, :project_key)
  config.environment = Rails.env
  config.ignore_environments = %w[test development]

  # airbrake.io supports various features that are out of scope for
  # Errbit. Disable them:
  config.job_stats           = false
  config.query_stats         = false
  config.performance_stats   = false
  config.remote_config       = false
end

Airbrake.add_filter do |notice|
  notice.ignore! if notice.stash[:exception].is_a?(ActionController::RoutingError)
end
