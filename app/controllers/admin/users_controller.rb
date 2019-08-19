class Admin::UsersController < ApplicationController
	layout 'admin_panel_sidenav'
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show]
	before_action :set_user, only: [:edit, :update, :show]

	def index
    @users = User.all.order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: 'admin/users/table', locals: {users: @users}}
      else
        format.html
      end
    end
	end

	def show
	end

	def update
		if @user.update_attributes(secure_params)
			redirect_to users_path, :notice => "User updated."
		else
			redirect_to users_path, :alert => "Unable to update user."
		end
	end

	def destroy
		@user.destroy
		redirect_to users_path, :notice => "User deleted."
	end

	private

	def secure_params
		params.require(:user).permit(:role, :approved)
	end

	def set_user
		@user = User.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search_query) if params[:filters]
  end

end
