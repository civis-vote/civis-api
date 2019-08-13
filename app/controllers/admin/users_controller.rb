class Admin::UsersController < ApplicationController
	# before_action :authenticate_user!
	before_action :set_user, only: [:update, :show, :destroy, :logs]

	def index
    @filtered_result = User.filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    @object_without_pagination = @filtered_result.data.distinct('users.id')
    @users = @object_without_pagination.page(params[:page]).per(30)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: 'admin/users/table', locals: {users: @users}}
      else
        format.html
      end
    end
	end

	def show
		@user = User.find(params[:id])
	end

	def update
		@user = User.find(params[:id])
		if @user.update_attributes(secure_params)
			redirect_to users_path, :notice => "User updated."
		else
			redirect_to users_path, :alert => "Unable to update user."
		end
	end

	def destroy
		user = User.find(params[:id])
		user.destroy
		redirect_to users_path, :notice => "User deleted."
	end

  def logs
  	@logs_without_pagination = @user.logs.order(created_at: :desc)
  	@logs = @logs_without_pagination.page(params[:page]).per(24)
    get_facets
    respond_to do |format|
      if request.xhr?
      	@user = User.find(params[:user])
        format.html {render partial: 'table.html', locals: {logs: @logs, facets: @facets}}
      else
        format.html
      end
    end
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
