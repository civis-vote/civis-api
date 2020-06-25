class SessionsController < Devise::SessionsController

	def create
		if user = User.find_by_email(params[:user][:email])
			if (user.admin? || user.moderator? || user.organisation_employee? ) && user.active?
				super
			else
				redirect_to new_user_session_path, flash_info: "You need to be a admin or moderator to sign in, Please contact administrator to continue"
			end
		else
			super
		end
	end
	
end