require 'devise/strategies/authenticatable'
module Devise
  module Strategies
    class CmAdminAuthenticatable < Authenticatable
      def valid?
        email.present?
      end

      def authenticate!
        @user = User.find_by(email: email)
        if @user&.disabled?
          fail!('Your account has been disabled. Please contact your administrator.')
        elsif @user&.can_access_admin_panel?
          success!
        else
          fail!('This email doesn’t match our records. Please contact your admin for help.')
        end
      end

      def success!
        @user.create_otp_request if CmAdmin.config.auth_method == :otp

        redirect!("/sign_in_with_credentials?email=#{URI.encode_www_form_component(@user.email)}")
      end

      private

      def email
        params[:identifier].presence || params.dig(:user, :email).presence || params[:email].presence
      end
    end
  end
end
Warden::Strategies.add(:cm_admin_authenticatable, Devise::Strategies::CmAdminAuthenticatable)
