class Admin::ConsultationResponsesController < ApplicationController
	layout "admin_panel_sidenav"
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :show, :approve, :reject]
	before_action :set_consultation_response, only: [:show, :approve, :reject]

	def index
	@consultation_responses = ConsultationResponse.order(created_at: :desc).published_consultation.filter_by(params[:page], filter_params.to_h, sort_params.to_h)
	respond_to do |format|
      if request.xhr?
        format.html {render partial: "admin/consultation_responses/table", locals: { consultation_responses: @consultation_responses } }
      else
        format.html
      end
    end
	end

	def show
	end

	def new
		@consultation_response = ConsultationResponse.new
	end

	def approve
		@consultation_response.approve
		redirect_back fallback_location: root_path,  flash_success_info: "Consultation Response was successfully approved."
	end

	def reject
		@consultation_response.reject
		redirect_back fallback_location: root_path,  flash_success_info: "Consultation Response was successfully rejected."
	end

	private

	def secure_params
		params.require(:consultation_response).permit(:user_id, :consultation_id, :response_text, :created_at)
	end

	def set_consultation_response
		@consultation_response = ConsultationResponse.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search, :response_filter) if params[:filters]
  end

end
