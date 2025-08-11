# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    layout 'cm_session'
    helper CmAdmin::ViewHelpers

    def validate_email
      warden.authenticate!(:cm_admin_authenticatable)
    end

    def new
      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)
      respond_with(resource, serialize_options(resource))
    end

    def validate_credentials
      CmAdmin.config.auth_method == :password ? validate_password : validate_otp
    end

    def validate_otp
      user = User.find_by(email: params[:email])
      otp = params[:otp]
      if user.present? && user.verify_otp(otp)
        sign_in(user)
        flash[:success] = 'Logged in successfully'
        user.update(last_active_at: Time.current) if user.last_active_at&.to_date != Date.today

        redirect_to current_user&.cm_role&.default_redirect_path || '/cm_admin/users'
      else
        flash[:alert] = 'Invalid OTP'
        redirect_back(fallback_location: sign_in_with_credentials_path(email: params[:email]))
      end
    end

    def validate_password
      user = User.find_by(email: params[:email])
      password = params[:password]
      if user.present? && user.valid_password?(password)
        sign_in(user)
        flash[:success] = 'Logged in successfully'
        user.update(last_active_at: Time.current) if user.last_active_at&.to_date != Date.today

        redirect_to current_user&.cm_role&.default_redirect_path || '/cm_admin/users'
      else
        flash[:alert] = 'Invalid password'
        redirect_back(fallback_location: sign_in_with_credentials_path(email: params[:email]))
      end
    end

    def resend_otp
      user = User.find_by(email: params[:email])
      if user.present?
        otp_request = user.create_otp_request
        if otp_request.errors.any?
          flash[:alert] = otp_request.errors.full_messages.join(', ')
        else
          flash[:success] = 'OTP has been resent to your email.'
        end
      else
        flash[:alert] = 'User not found.'
      end
      redirect_back(fallback_location: sign_in_with_credentials_path(email: params[:email]))
    end

    def sign_in_with_credentials
      @email = params[:email]
    end
  end
end
