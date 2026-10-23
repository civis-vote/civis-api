class OauthController < ApplicationController
	 def redirect_to_provider
    if request.env['REQUEST_URI'].include?('signin_google')
    	 redirect_to omniauth_path('/users/auth/google_oauth2')
    elsif request.env['REQUEST_URI'].include?('signin_linkedin')
    	 redirect_to omniauth_path('/users/auth/linkedin')
    elsif request.env['REQUEST_URI'].include?('signin_facebook')
    	 redirect_to omniauth_path('/users/auth/facebook')
    end
  end

  def callback
    return unless request.env['omniauth.auth']['info']

    user = User.find_by(email: request.env['omniauth.auth']['info'][:email])
    unless user
      auth_info = request.env['omniauth.auth']
      user = User.public_send("create_from_#{auth_info[:provider]}", auth_info[:info], auth_info[:uid])
    end
    user.api_keys.create unless user.api_keys.live.present?
    redirect_to(URI::HTTP.build(client_url.merge({ path: '/auth/success', query: "access_token=#{user.live_api_key.access_token}" })).to_s, allow_other_host: true)
  end

  def failure
    redirect_to(URI::HTTP.build(client_url.merge({ path: '/auth/failure' })).to_s, allow_other_host: true)
  end

  private

  def omniauth_path(path)
    params[:client].present? ? "#{path}?client=#{CGI.escape(params[:client])}" : path
  end

  # OmniAuth echoes request-phase query params back in `omniauth.params`.
  # Only allowlisted client identifiers select a redirect origin; anything
  # else falls back to the default client.
  def client_url
    if request.env.dig('omniauth.params', 'client') == 'civis_v2' && Rails.application.config.client_v2_url[:host].present?
      Rails.application.config.client_v2_url
    else
      Rails.application.config.client_url
    end
  end
end
