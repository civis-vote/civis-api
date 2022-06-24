class OauthController < ApplicationController
  skip_before_action :verify_authenticity_token

	def redirect_to_provider
    if request.env["REQUEST_URI"].include?("signin_google")
      res = HTTP.post("https://#{Rails.application.routes.default_url_options[:host]}/users/auth/google_oauth2")
      redirect_to res.as_json['headers'].find('Location').first[1]
    elsif request.env["REQUEST_URI"].include?("signin_linkedin")
    	# redirect_to "/users/auth/linkedin"
    elsif request.env["REQUEST_URI"].include?("signin_facebook")
      # HTTP.post("http: //127.0.0.1:3003/users/auth/facebook")
      # a = HTTP.post("http://localhost:3003/users/auth/facebook")
      # redirect_to a.as_json['headers'].find('Location').first[1]
    end
  end

  def callback
    return unless request.env["omniauth.auth"]["info"]
    user = User.find_by(email: request.env["omniauth.auth"]["info"][:email])
    unless user
      auth_info = request.env["omniauth.auth"]
      user = User.public_send("create_from_#{auth_info[:provider]}", auth_info[:info], auth_info[:uid])
    end
    user.api_keys.create unless user.api_keys.live.present?
    redirect_to URI::HTTP.build(Rails.application.config.client_url.merge!({path: "/auth/success", query: "access_token=#{user.live_api_key.access_token}"})).to_s
  end

  def failure
    redirect_to URI::HTTP.build(Rails.application.config.client_url.merge!({path: "/auth/failure"})).to_s
  end

end