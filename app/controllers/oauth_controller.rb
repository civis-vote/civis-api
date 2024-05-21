class OauthController < ApplicationController
	 def redirect_to_provider
    if request.env['REQUEST_URI'].include?('signin_google')
    	 redirect_to '/users/auth/google_oauth2'
    elsif request.env['REQUEST_URI'].include?('signin_linkedin')
    	 redirect_to '/users/auth/linkedin'
    elsif request.env['REQUEST_URI'].include?('signin_facebook')
    	 redirect_to '/users/auth/facebook'
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
    redirect_to(URI::HTTP.build(Rails.application.config.client_url.merge!({ path: '/auth/success', query: "access_token=#{user.live_api_key.access_token}" })).to_s, allow_other_host: true)
  end

  def failure
    redirect_to(URI::HTTP.build(Rails.application.config.client_url.merge!({ path: '/auth/failure' })).to_s, allow_other_host: true)
  end
end
