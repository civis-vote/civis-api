class OauthController < ApplicationController
  PROVIDERS = {
    'signin_google' => 'google_oauth2',
    'signin_linkedin' => 'linkedin',
    'signin_facebook' => 'facebook'
  }.freeze

  def redirect_to_provider
    provider = PROVIDERS.find { |slug, _| request.env['REQUEST_URI'].include?(slug) }&.last
    return unless provider

    path = "/users/auth/#{provider}"
    path += "?client=#{CGI.escape(params[:client])}" if params[:client].present?
    redirect_to path
  end

  def callback
    auth = request.env['omniauth.auth']
    return unless auth['info']

    user = User.find_by(email: auth['info'][:email])
    user ||= User.public_send("create_from_#{auth[:provider]}", auth[:info], auth[:uid])
    user.api_keys.create unless user.api_keys.live.present?

    client_redirect '/auth/success', "access_token=#{user.live_api_key.access_token}"
  end

  def failure
    client_redirect '/auth/failure'
  end

  private

  def client_redirect(path, query = nil)
    url = URI::HTTP.build(client_url.merge({ path: path, query: query })).to_s
    redirect_to url, allow_other_host: true
  end

  # OmniAuth echoes request-phase query params back in `omniauth.params`.
  # `civis_v2` redirects to the configured v2 client; anything else falls
  # back to the default client.
  def client_url
    if request.env.dig('omniauth.params', 'client') == 'civis_v2' && Rails.application.config.client_v2_url[:host].present?
      Rails.application.config.client_v2_url
    else
      Rails.application.config.client_url
    end
  end
end
