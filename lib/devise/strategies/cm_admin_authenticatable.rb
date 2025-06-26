require 'devise/strategies/authenticatable'
module Devise
  module Strategies
    class CmAdminAuthenticatable < Authenticatable
      def valid?
        params.dig(:user, :email).present?
      end

      def authenticate!
        @user = User.find_by(email: params[:user][:email])
        if @user&.can_access_admin_panel?
          success!
        else
          fail!('This email doesn’t match our records. Please contact your admin for help.')
        end
      end

      def success!
        @user.create_otp_request if CmAdmin.config.auth_method == :otp
        redirect!("/sign_in_with_credentials?email=#{CGI.escape(@user.email)}")
      end
    end
  end
end
Warden::Strategies.add(:cm_admin_authenticatable, Devise::Strategies::CmAdminAuthenticatable)
