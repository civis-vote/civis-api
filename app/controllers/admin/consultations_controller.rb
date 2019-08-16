class Admin::ConsultationsController < ApplicationController
	layout 'admin_panel_sidenav'
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show]
	before_action :set_consultation, only: [:edit, :update, :show]

	def index
    @consultations = Consultation.all.includes(:ministry, :created_by).order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: 'admin/consultations/table', locals: {consultations: @consultations}}
      else
        format.html
      end
    end
	end

	def show
	end

	def update
		if @consultation.update_attributes(secure_params)
			redirect_back fallback_location: root_path, flash_success_info: 'Consultation details was successfully updated.'
		else
			redirect_back fallback_location: root_path, flash_info: 'Consultation details was not successfully updated.'
		end
	end

	def destroy
		@consultation.destroy
		redirect_to users_path, :notice => "User deleted."
	end

	private

	def secure_params
		params.require(:consultation).permit(:title, :url)
	end

	def set_consultation
		@consultation = Consultation.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search_query, :status_filter) if params[:filters]
  end

end
