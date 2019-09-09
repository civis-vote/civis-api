class ApplicationController < ActionController::Base
	protect_from_forgery with: :null_session
	skip_before_action :verify_authenticity_token
	add_flash_types :flash_info, :flash_success_info

  def require_admin
    Current.user = current_user
    unless user_signed_in? && (current_user.admin? || current_user.moderator?)
      sign_out current_user
      redirect_to root_path, flash_info: "You need to be a admin or moderator to sign in, Please contact administrator to continue"
    end
  end

  def after_sign_in_path_for(resource)
    if resource.admin? || resource.moderator?
    	admin_users_path
    else
      root_path
    end
  end
end