class Admin::NotificationTypesController < ApplicationController
	layout "admin_panel_sidenav"
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show, :destroy]
	before_action :set_notification_type, only: [:edit, :update, :show, :destroy]

	def index
		@notification_types = NotificationType.all.order(notification_type: :asc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
        respond_to do |format|
			if request.xhr?
				format.html {render partial: "admin/notification_types/table", locals: { notification_types: @notification_types } }
			else
				format.html
			end
	    end
	end

	def show
	end

	def update
		if @notification_type.update(secure_params)
			redirect_to admin_notification_type_path(@notification_type), flash_success_info: "Notification Type was successfully updated."
		else
			redirect_back fallback_location: root_path, flash_info: "Notification Type was not successfully updated."
		end
	end

	def destroy
		@notification_type.destroy
		redirect_to admin_notification_types_path, flash_success_info: "Notification Type was successfully deleted."
	end

	def new
		@notification_type = NotificationType.new
	end

	def create
		@notification_type = NotificationType.new(secure_params)
		if NotificationType.where(notification_type: secure_params[:notification_type]).empty?
			if @notification_type.save 
				redirect_to admin_notification_type_path(@notification_type), flash_success_info: "Notification Type was successfully created."
			else
				flash[:flash_info] = "Notification Type was not successfully created."
			render :new
			end
		else
			flash[:flash_info] = "Notification Type is already present and duplicate notification types cannot be inserted. Please Update the notification type instead."
			render :new
		end
  	end

	private

	def secure_params
		params.require(:notification_type).permit(:notification_type, :notification_sub_text, :notification_main_text)
	end

	def set_notification_type
		@notification_type = NotificationType.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search_notification_type) if params[:filters]
  end

end
