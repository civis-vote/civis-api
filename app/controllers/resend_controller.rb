class ResendController < ApplicationController
    def create
        user = User.find_by(email: params[:user][:email])
        if params[:user][:email].empty?
            redirect_back fallback_location: root_path, flash_success_info: "Please enter an email id"
        elsif user.nil?
            redirect_back fallback_location: root_path, flash_success_info: "If your account exists, you would have received an email on your registered email address. Please check this email and complete your email verification. If you haven’t received the email, please contact info@civis.vote for support"
        elsif user.confirmed_at
            redirect_back fallback_location: root_path, flash_success_info: "Email has already been confirmed"
        else
            VerifyUserEmailJob.perform_later(user)
            redirect_to root_path, flash_success_info: "Confirmation email sent."
        end 
    end

    def resend_params
        params.require(:resend).permit(:user)
    end
end