require 'devise/strategies/authenticatable'
module Devise
  module Strategies
    class CmAdminAuthenticatable < Authenticatable
      def valid?
        request.post? && identifier_value.present?
      end

      def authenticate!
        @user = CmAdmin.config.user_lookup.call(identifier_value)
        if @user&.disabled?
          fail!('Your account has been disabled. Please contact your administrator.')
        elsif @user&.can_access_admin_panel?
          success!
        else
          fail!("This account doesn't match our records. Please contact your admin for help.")
        end
      end

      def success!
        if CmAdmin.config.auth_method == :otp
          otp_request = @user.create_otp_request(delivery_channel: OtpRequest.delivery_channel_for(identifier_value))
          return fail!(otp_request.errors.full_messages.to_sentence) if otp_request.errors.any?
        end
        redirect!("/sign_in_with_credentials?#{Rack::Utils.build_query(identifier: identifier_value)}")
      end

      private

      def identifier_value
        params[:identifier].presence || params[:email].presence || params.dig(:user, :email).presence
      end
    end
  end
end
Warden::Strategies.add(:cm_admin_authenticatable, Devise::Strategies::CmAdminAuthenticatable)
