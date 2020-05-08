class ResendController < ApplicationController
    def create
        user = User.find_by(email: params[:user][:email])
        if params[:user][:email].empty?
            redirect_back fallback_location: root_path, flash_success_info: "Please enter an email id"
        elsif user.nil?
            redirect_back fallback_location: root_path, flash_success_info: "User does not exist"
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