require Rails.root.join("config/omniauth_strategies/google_oauth2_with_pkce")

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :google_oauth2_with_pkce, Rails.application.credentials.dig(:omniauth, :google, :client_id), Rails.application.credentials.dig(:omniauth, :google, :client_secret)
	provider :facebook, Rails.application.credentials.dig(:omniauth, :facebook, :app_id), Rails.application.credentials.dig(:omniauth, :facebook, :app_secret)
	provider :linkedin, Rails.application.credentials.dig(:omniauth, :linkedin, :client_id), Rails.application.credentials.dig(:omniauth, :linkedin, :client_secret) 
	on_failure { |env| OauthController.action(:failure).call(env) }
end
OmniAuth.config.allowed_request_methods = %i[get]
OmniAuth.config.silence_get_warning = true