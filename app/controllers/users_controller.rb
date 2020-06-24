class UsersController < ApplicationController
	def edit_invite
    @user = User.find_by_invitation_token(params[:invitation_token], true)
    redirect_to root_path unless @user.present?
  end

  def accepting_invite
    user = User.accept_invitation!(secure_params)
    sign_out user
    redirect_to root_path
  end

  private

  def secure_params
    params.require(:user).permit(:profile_picture, :first_name, :last_name, :password, :invitation_token)
  end
end