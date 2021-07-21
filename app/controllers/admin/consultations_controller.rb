class Admin::ConsultationsController < ApplicationController
	layout "admin_panel_sidenav"
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show, :create, :show_response_submission_message, :update_response_submission_message, :import_responses]
	before_action :set_consultation, only: [:edit, :update, :show, :publish, :reject, :destroy, :featured, :unfeatured, :check_active_ministry, :edit_hindi_summary, :edit_english_summary, :extend_deadline, :create_response_round, :invite_respondents, :page_component, :show_response_submission_message, :update_response_submission_message, :import_responses]
	before_action :set_organisation, only: [:show, :invite_respondents]

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
		@response_rounds = @consultation.response_rounds.order(:created_at)
    @consultation_respondents = Respondent.where(response_round_id: @consultation.response_round_ids)
    @invitation_sent_count = @consultation_respondents.size
    @responses_count = ConsultationResponse.where(response_round: @response_rounds.last).size
    @question = Question.new
    @question.sub_questions.build
    @respondents = @organisation ? @organisation.respondents.search_user_query(params[:search]).uniq(&:user_id) : @consultation_respondents.search_user_query(params[:search]).uniq(&:user_id)
    @consultation_response_rounds = Consultation.includes(:response_rounds)
		@page = @consultation.page
		ConsultationHindiSummary.find_or_create_by(consultation: @consultation)
    @hindi_summary_page = ConsultationHindiSummary.find_by(consultation: @consultation).page
    respond_to do |format|
      if request.xhr?
        format.html {render partial: "users/admin/invite_respondents_table", locals: {consultations: @consultations}}
      else
        format.html
      end
    end
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
      flash_message = params[:consultation_create].present? ? 'Consultation was successfully created.' : 'Consultation English Summary was successfully updated.'
      redirect_to admin_consultation_path(@consultation), flash_success_info: flash_message
    else
      redirect_to admin_consultation_path(@consultation), flash_info: "Consultation English Summary was not successfully updated."
    end
  end

  def edit_english_summary
    @english_summary_page = @consultation.page
  end

  def hindi_page_component
		@consultation = Consultation.find(params[:id])
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
      redirect_to admin_consultation_path(@consultation), flash_success_info: "Consultation hindi summary page details was successfully updated."
    else
      redirect_to admin_consultation_path(@consultation), flash_info: "Consultation hindi summary page details was not successfully updated."
    end
  end

  def edit
  	@page = @consultation.page	
  end

	def update
		if @consultation.update(secure_params)
	    if @consultation.page.present?
	      @page = @consultation.page
	    else
	      @page = @consultation.create_page
	    end
	    @consultation.update_reading_time
			redirect_to admin_consultation_path(@consultation), flash_success_info: "Consultation details was successfully updated."
		else
			redirect_back fallback_location: root_path, flash_info: "Consultation details was not successfully updated."
		end
	end

	def new
    @consultation = Consultation.new
    @page = @consultation.page
  end

  def create
    @consultation = Consultation.new(secure_params.merge(created_by_id: current_user.id))
    if @consultation.save
      redirect_to edit_english_summary_admin_consultation_path(@consultation)
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

	def extend_deadline
    @consultation.extend_deadline(secure_params[:response_deadline])
    redirect_back fallback_location: root_path,  flash_success_info: "Consultation deadline was extended and successfully published."
  end

  def create_response_round
    @consultation.create_response_round
    @consultation.submitted!
    redirect_to edit_english_summary_admin_consultation_path(@consultation)
  end

  def invite_respondents
    respondent_ids = params[:respondent][:ids].present? ? params[:respondent][:ids].to_unsafe_h : ""
    emails = params[:respondent][:emails].split(",")
    Respondent.invite_respondent(@consultation, @organisation, respondent_ids, emails, current_user)
    redirect_back fallback_location: root_path,  flash_success_info: "Respondent was successfully invited."
  end

  def show_response_submission_message
    
  end

  def update_response_submission_message
    if @consultation.update(secure_params)
      redirect_to admin_consultation_path,  flash_success_info: "Consultation response submission message was successfully updated."
    else
      redirect_to admin_consultation_path,  flash_info: "Consultation response submission message was not successfully updated."
    end
  end

  def import_responses
    if (params[:consultation].present? && params[:consultation][:file].present?)
      import = ConsultationResponse.import_responses(params[:consultation][:file])
      if import[:status] == "true"
        redirect_to admin_consultation_path(@consultation), flash_success_info: "#{import[:records_count]} responses imported successfully"
      else
        redirect_to admin_consultation_path(@consultation), flash_info: "Something went wrong, please try again later."
      end
    else
      redirect_to admin_consultation_path(@consultation), flash_info: "File not found."
    end
  end

	private

	def secure_params
		params.require(:consultation).permit(:title, :url, :ministry_id, :response_deadline, :summary, :consultation_feedback_email, :review_type, :visibility, :response_submission_message, :private_response)
	end

	def set_consultation
		@consultation = Consultation.find(params[:id])
	end

	def set_organisation
		@organisation = @consultation.organisation
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
