class Admin::MinistriesController < ApplicationController
	layout 'admin_panel_sidenav'
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show, :approve, :reject, :destroy]
	before_action :set_ministry, only: [:edit, :update, :show, :approve, :reject, :destroy]

	def index
    @ministries = Ministry.all.includes(:created_by).order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: 'admin/ministries/table', locals: { ministries: @ministries } }
      else
        format.html
      end
    end
	end

	def show
	end

	def update
		if @ministry.update_attributes(secure_params)
			redirect_back fallback_location: root_path, flash_success_info: 'Ministry details was successfully updated.'
		else
			redirect_back fallback_location: root_path, flash_info: 'Ministry details was not successfully updated.'
		end
	end

	def destroy
		@ministry.destroy
		redirect_to admin_ministries_path, flash_success_info: 'Ministry was successfully deleted.'
	end

	def approve
		@ministry.update_attributes(is_approved: true)
		redirect_back fallback_location: root_path,  flash_success_info: 'Ministry was successfully approved.'
	end

	def reject
		@ministry.update_attributes(is_approved: false)
		redirect_back fallback_location: root_path,  flash_success_info: 'Ministry was successfully rejected.'
	end

	private

	def secure_params
		params.require(:ministry).permit(:name, :level, :poc_email_primary, :poc_email_secondary, :logo)
	end

	def set_ministry
		@ministry = Ministry.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search_query, :status_filter) if params[:filters]
  end

end
