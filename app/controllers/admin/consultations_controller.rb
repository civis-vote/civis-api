class Admin::ConsultationsController < ApplicationController
	layout "admin_panel_sidenav"
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show, :create]
	before_action :set_consultation, only: [:edit, :update, :show, :publish, :reject, :destroy, :featured, :unfeatured, :check_active_ministry]

	def index
    @consultations = Consultation.all.includes(:ministry, :created_by).order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: "admin/consultations/table", locals: {consultations: @consultations}}
      else
        format.html
      end
    end
	end

	def show
		@page = @consultation.page
	end

	def page_component
		@consultation = Consultation.find(params[:id])
    components = page_params.delete(:components)
    if @consultation.page.present?
      @page = @consultation.page
    else
      @page = @consultation.page.new(page_params)
    end
    if @page.save
      @page.save_content(components)
      sleep(2.0)
      redirect_to admin_consultation_path(@consultation), notice: 'Page was successfully updated.'
    else
      render :new
    end
  end

	def update
		if @consultation.update(secure_params)
			redirect_to admin_consultation_path(@consultation), flash_success_info: "Consultation details was successfully updated."
		else
			redirect_back fallback_location: root_path, flash_info: "Consultation details was not successfully updated."
		end
	end

	def new
    @consultation = Consultation.new
  end

  def create
    @consultation = Consultation.new(secure_params.merge(created_by_id: current_user.id))
    if @consultation.save
      redirect_to admin_consultation_path(@consultation), flash_success_info: "Consultation was successfully created."
    else
    	flash[:flash_info] = "Consultation was not successfully created."
      render :new
    end
  end

	def destroy
		@consultation.destroy
		redirect_to admin_consultations_path, flash_success_info: "Consultation was successfully deleted."
	end

	def publish
		@consultation.publish
		redirect_back fallback_location: root_path,  flash_success_info: "Consultation was successfully approved."
	end

	def reject
		@consultation.reject
		redirect_back fallback_location: root_path,  flash_success_info: "Consultation was successfully rejected."
	end	

	def featured
		@consultation.featured
		redirect_back fallback_location: root_path,  flash_success_info: "Consultation was successfully updated as featured."
	end

	def unfeatured
		@consultation.unfeatured
		redirect_back fallback_location: root_path,  flash_success_info: "Consultation was successfully updated as unfeatured."
	end

	def check_active_ministry
		ministry = Ministry.find(params[:ministry_id])
		render partial: "consultation_ministry", locals: { consultation: @consultation, selected_ministry: ministry } if ministry
	end

	def export_as_excel
		respond_to do |format|
			if params[:consultation_responses]
				consultation = Consultation.find(params[:id].to_i)
				consultation_responses = consultation.responses.order(created_at: :desc)
				ConsultationResponsesExportEmailJob.perform_later(consultation_responses.to_a, current_user.email)
      	format.html { redirect_back fallback_location: admin_consultations_path, flash_success_info: "Consultations Responses was successfully exported will email you shortly." }
			else
				@consultations = Consultation.all.includes(:ministry, :created_by).order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
				@consultations = @consultations.data.list(@consultations.facets.filtered_count, nil, nil)
				ConsultationExportEmailJob.perform_later(@consultations.data.to_a, current_user.email)
      	format.html { redirect_back fallback_location: admin_consultations_path, flash_success_info: "Consultations was successfully exported will email you shortly." }
			end
    end
	end

	private

	def secure_params
		params.require(:consultation).permit(:title, :url, :ministry_id, :response_deadline, :summary, :consultation_feedback_email, :review_type, :visibility)
	end

	def set_consultation
		@consultation = Consultation.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search_query, :status_filter, :visibility_filter) if params[:filters]
  end

  def page_params
    params.require(:page).permit(:components)
  end
end
