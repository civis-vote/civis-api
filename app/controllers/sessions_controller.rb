class SessionsController < Devise::SessionsController

	def create
		if user = User.find_by_email(params[:user][:email])
			if user.admin?
				super
			else
				redirect_to new_user_session_path, flash: { notice: "You need to be a admin to sign in, Please contact administrator to continue" }
			end
		else
			super
		end
	end
	
end