class Admin::GlossaryMappingsController < ApplicationController
	layout "admin_panel_sidenav"
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show, :destroy]
	before_action :set_wordindex, only: [:edit, :update, :show, :destroy]

	def index
    # @glossary_mappings = GlossaryMapping.all.includes(:created_by).order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
	@glossary_mappings = GlossaryMapping.all.order(consultation_id: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: "admin/wordindices/table_glossary_mapping", locals: { glossary_mappings: @glossary_mappings } }
      else
        format.html
      end
    end
	end

	def show
	end

	def update
		if @glossary_mapping.update(secure_params)
			redirect_to admin_glossary_mapping_path(@glossary_mapping), flash_success_info: "Glossary Mapping details was successfully updated."
		else
			redirect_back fallback_location: root_path, flash_info: "Glossary Mapping details was not successfully updated."
		end
	end

	def destroy
		@glossary_mapping.destroy
		redirect_to admin_glossary_mappings_path, flash_success_info: "Glossary Mapping Record was successfully deleted."
	end

	def new
		@glossary_mapping = GlossaryMapping.new
	end

	def create
    @glossary_mapping = GlossaryMapping.new(secure_params)
	if GlossaryMapping.where(consultation_id: secure_params[:consultation_id], glossary_id: secure_params[:glossary_id]).empty?
		if @glossary_mapping.save
			redirect_to admin_glossary_mappings_path, flash_success_info: "Glossary mapping Index was successfully created."
		else
			flash[:flash_info] = "Mapping was not successfull"
		render :new
		end
	else
		flash[:flash_info] = "Mapping was duplicate. Hence not succesfull"
		redirect_to admin_glossary_mappings_path
	end
	end
  

	private

	def secure_params
		params.require(:glossary_mapping).permit(:consultation_id, :glossary_id)
	end

	def set_wordindex
		@glossary_mapping = GlossaryMapping.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search) if params[:filters]
  end

end
