class Admin::CaseStudiesController < ApplicationController
	layout 'admin_panel_sidenav'
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show, :destroy]
	before_action :set_case_study, only: [:edit, :update, :show, :destroy]

	def index
    @case_studies = CaseStudy.all.includes(:created_by).order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: 'admin/case_studies/table', locals: { case_studies: @case_studies } }
      else
        format.html
      end
    end
	end

	def show
	end

	def update
		if @case_study.update(secure_params)
			redirect_to admin_case_study_path(@case_study), flash_success_info: 'Case Study details was successfully updated.'
		else
			redirect_back fallback_location: root_path, flash_info: 'Case Study details was not successfully updated.'
		end
	end

	def destroy
		@case_study.destroy
		redirect_to admin_case_studies_path, flash_success_info: 'Case Study was successfully deleted.'
	end

	def new
		@case_study = CaseStudy.new
	end

	def create
    @case_study = CaseStudy.new(secure_params.merge(created_by_id: current_user.id))
    if @case_study.save
      redirect_to admin_case_study_path(@case_study), flash_success_info: 'Case Study was successfully created.'
    else
    	flash[:flash_info] = 'Case Study was not successfully created.'
      render :new
    end
  end

	private

	def secure_params
		params.require(:case_study).permit(:name, :ministry_name, :no_of_citizens, :url)
	end

	def set_case_study
		@case_study = CaseStudy.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search) if params[:filters]
  end

end
