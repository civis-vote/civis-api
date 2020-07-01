class Organisation::ConsultationsController < ApplicationController
	layout "organisation_sidenav"
	before_action :authenticate_user!
  before_action :require_organisation_employee, only: [:index, :create, :show, :edit]
  before_action :set_organisation, only: [:index, :create, :show, :edit, :update, :page_component, :hindi_page_component, :edit_hindi_summary, :destroy, :publish]
  before_action :set_consultation, only: [:show, :edit, :update, :page_component, :hindi_page_component, :edit_hindi_summary, :destroy, :publish]

	def index
    @consultation = Consultation.new
    @page = @consultation.page
    @consultations = Consultation.where(organisation_id: @organisation.id).includes(:ministry, :created_by).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: "organisation/consultations/table", locals: {consultations: @consultations}}
      else
        format.html
      end
    end
	end

	def show
		@page = @consultation.page
		ConsultationHindiSummary.find_or_create_by(consultation: @consultation)
	end

	def edit_hindi_summary
		@hindi_summary_page = ConsultationHindiSummary.find_by(consultation: @consultation).page
	end

	def page_component
    components = page_params.delete(:components)
    if @consultation.page.present?
      @page = @consultation.page
    else
      @page = @consultation.page.new(page_params)
    end
    if @page.save
      @page.save_content(components)
      sleep(2.0)
      @consultation.update_reading_time
      redirect_to organisation_consultation_path(@consultation), flash_success_info: "Consultation English Summary was successfully updated."
    else
      redirect_to organisation_consultation_path(@consultation), flash_info: "Consultation English Summary was not successfully updated."
    end
  end

  def hindi_page_component
		@consultation_hindi_summary = ConsultationHindiSummary.find_or_create_by(consultation: @consultation)
    components = page_params.delete(:components)
    if @consultation_hindi_summary.page.present?
      @hindi_summary_page = @consultation_hindi_summary.page
    else
      @hindi_summary_page = @consultation_hindi_summary.page.new(page_params)
    end
    if @hindi_summary_page.save
      @hindi_summary_page.save_content(components)
      sleep(2.0)
      redirect_to organisation_consultation_path(@consultation), flash_success_info: "Consultation hindi summary page details was successfully updated."
    else
      redirect_to organisation_consultation_path(@consultation), flash_info: "Consultation hindi summary page details was not successfully updated."
    end
  end

  def edit
  	@page = @consultation.page	
  end

	def update
		if @consultation.update(secure_params)
			redirect_to organisation_consultation_path(@consultation), flash_success_info: "Consultation details was successfully updated."
		else
			redirect_back fallback_location: root_path, flash_info: "Consultation details was not successfully updated."
		end
	end

	def new
    
  end

  def create
    @consultation = Consultation.new(secure_params.merge(created_by_id: current_user.id))
    if @consultation.save
      redirect_to organisation_consultations_path(sort:{sort_column: "created_at", sort_direction: "desc"}), flash_success_info: "Consultation was successfully created."
    else
      redirect_to organisation_consultations_path(sort:{sort_column: "created_at", sort_direction: "desc"}), flash_info: "Consultation was not successfully created."
    end
  end

	def destroy
		@consultation.destroy
		redirect_to organisation_consultations_path(sort:{sort_column: "created_at", sort_direction: "desc"}), flash_success_info: "Consultation was successfully deleted."
	end

	def publish
		@consultation.publish
		redirect_back fallback_location: root_path,  flash_success_info: "Consultation was successfully approved."
	end

	private

	def secure_params
		params.require(:consultation).permit(:title, :url, :ministry_id, :response_deadline, :summary, :consultation_feedback_email, :review_type, :visibility, :private_response, :organisation_id)
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

  def set_organisation
		@organisation = Organisation.find(current_user.organisation_id)
	end
end
