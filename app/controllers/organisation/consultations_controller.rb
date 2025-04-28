class Organisation::ConsultationsController < ApplicationController
  layout 'organisation_sidenav'
  before_action :authenticate_user!
  before_action :require_organisation_employee, only: %i[index create show edit import_responses]
  before_action :set_organisation, only: %i[index create show edit update edit_hindi_summary edit_odia_summary edit_marathi_summary destroy publish edit_english_summary extend_deadline create_response_round invite_respondents import_responses update_english_summary update_hindi_summary update_odia_summary update_marathi_summary]
  before_action :set_consultation, only: %i[show edit update edit_hindi_summary edit_odia_summary edit_marathi_summary destroy publish edit_english_summary extend_deadline create_response_round invite_respondents import_responses update_english_summary update_hindi_summary update_odia_summary update_marathi_summary]
  def index
    @consultation = Consultation.new
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
    @response_rounds = @consultation.response_rounds.order(:created_at)
    @consultation_respondents = Respondent.where(response_round_id: @consultation.response_round_ids)
    @invitation_sent_count = @consultation_respondents.size
    @responses_count = ConsultationResponse.where(response_round_id: @response_rounds.last.id).size
    @question = Question.new
    @question.sub_questions.build
    @respondents = @organisation.respondents.search_user_query(params[:search]).uniq(&:user_id)
    @consultation_response_rounds = Consultation.includes(:response_rounds)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: "users/invite_respondents_table", locals: {consultations: @consultations}}
      else
        format.html
      end
    end
  end

  def edit_english_summary
    @english_summary = @consultation.english_summary
  end

  def edit_hindi_summary
    @hindi_summary = @consultation.hindi_summary
  end

  def edit_odia_summary
    @odia_summary = @consultation.odia_summary
  end

  def edit_marathi_summary
    @marathi_summary = @consultation.marathi_summary
  end

  def update_english_summary
    if @consultation.update(english_summary: params[:consultation][:english_summary])
      @consultation.update_reading_time
      flash_message = params[:consultation_create].present? ? 'Consultation was successfully created.' : 'Consultation English Summary was successfully updated.'
      redirect_to admin_consultation_path(@consultation), flash_success_info: flash_message
    else
      redirect_to admin_consultation_path(@consultation), flash_info: "Consultation English Summary was not successfully updated."
    end
  end

  def update_hindi_summary
    if @consultation.update(hindi_summary: params[:consultation][:hindi_summary])
      @consultation.update_reading_time
      flash_message = params[:consultation_create].present? ? 'Consultation was successfully created.' : 'Consultation Hindi Summary was successfully updated.'
      redirect_to admin_consultation_path(@consultation), flash_success_info: flash_message
    else
      redirect_to admin_consultation_path(@consultation), flash_info: "Consultation Hindi Summary was not successfully updated."
    end
  end

  def update_odia_summary
    if @consultation.update(odia_summary: params[:consultation][:odia_summary])
      @consultation.update_reading_time
      flash_message = params[:consultation_create].present? ? 'Consultation was successfully created.' : 'Consultation Odia Summary was successfully updated.'
      redirect_to admin_consultation_path(@consultation), flash_success_info: flash_message
    else
      redirect_to admin_consultation_path(@consultation), flash_info: 'Consultation Odia Summary was not successfully updated.'
    end
  end

  def update_marathi_summary
    if @consultation.update(marathi_summary: params[:consultation][:marathi_summary])
      @consultation.update_reading_time
      flash_message = params[:consultation_create].present? ? 'Consultation was successfully created.' : 'Consultation Marathi Summary was successfully updated.'
      redirect_to admin_consultation_path(@consultation), flash_success_info: flash_message
    else
      redirect_to admin_consultation_path(@consultation), flash_info: "Consultation Marathi Summary was not successfully updated."
    end
  end

  def edit
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
      redirect_to edit_english_summary_organisation_consultation_path(@consultation)
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
  
  def extend_deadline
    @consultation.extend_deadline(secure_params[:response_deadline])
    redirect_back fallback_location: root_path,  flash_success_info: "Consultation deadline was extended and successfully published."
  end

  def create_response_round
    @consultation.create_response_round
    @consultation.submitted!
    redirect_to edit_english_summary_organisation_consultation_path(@consultation)
  end

  def invite_respondents
    respondent_ids = params[:respondent][:ids].present? ? params[:respondent][:ids].to_unsafe_h : ""
    emails = params[:respondent][:emails].split(",")
    Respondent.invite_respondent(@consultation, @organisation, respondent_ids, emails, current_user)
    redirect_back fallback_location: root_path,  flash_success_info: "Respondent was successfully invited."
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
    params.require(:consultation).permit(:title, :title_hindi, :title_odia, :title_marathi, :url, :ministry_id, :response_deadline, :summary, :consultation_feedback_email, :review_type, :visibility, :private_response, :organisation_id, :is_satisfaction_rating_optional, :allow_discuss_engage_response)
  end

  def set_consultation
    @consultation = Consultation.find(params[:id])
  end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search_query, :status_filter, :visibility_filter, :search_user_query) if params[:filters]
  end

  def set_organisation
    @organisation = Organisation.find(current_user.organisation_id)
  end
end