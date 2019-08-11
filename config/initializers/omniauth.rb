Rails.application.config.middleware.use OmniAuth::Builder do
	provider :google_oauth2, Rails.application.credentials.dig(:omniauth, :google, :client_id), Rails.application.credentials.dig(:omniauth, :google, :client_secret)
	provider :facebook, Rails.application.credentials.dig(:omniauth, :facebook, :app_id), Rails.application.credentials.dig(:omniauth, :facebook, :app_secret)
	provider :linkedin, Rails.application.credentials.dig(:omniauth, :linkedin, :client_id), Rails.application.credentials.dig(:omniauth, :linkedin, :client_secret) 
	on_failure { |env| OauthController.action(:failure).call(env) }
end