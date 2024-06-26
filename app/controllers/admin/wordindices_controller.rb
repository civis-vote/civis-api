class Admin::WordindicesController < ApplicationController
	layout "admin_panel_sidenav"
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show, :destroy]
	before_action :set_wordindex, only: [:edit, :update, :show, :destroy]

	def index
    # @wordindices = Wordindex.all.includes(:created_by).order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
	@wordindices = Wordindex.all.includes(:created_by).order(word: :asc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        # format.html {render partial: "admin/wordindices/table", locals: { wordindices: @word_indices } }
		format.html {render partial: "admin/wordindices/table", locals: { wordindices: @wordindices } }
      else
        format.html
      end
    end
	end

	def show
	end

	def update
		if @wordindex.update(secure_params)
			redirect_to admin_wordindex_path(@wordindex), flash_success_info: "Word Index details was successfully updated."
		else
			redirect_back fallback_location: root_path, flash_info: "Word Index details was not successfully updated."
		end
	end

	def destroy
		@wordindex.destroy
		redirect_to admin_wordindices_path, flash_success_info: "Word Index was successfully deleted."
	end

	def new
		@wordindex = Wordindex.new
	end

	def create
		@wordindex = Wordindex.new(secure_params.merge(created_by: current_user))
		if Wordindex.where(word: secure_params[:word]).empty?
			if @wordindex.save 
				redirect_to admin_wordindex_path(@wordindex), flash_success_info: "Word Index was successfully created."
			else
				flash[:flash_info] = "Word Index was not successfully created."
			render :new, status: :unprocessable_entity
			end
		else
			flash[:flash_info] = "Word is already present and duplicate words cannot be inserted. Please Update the word instead."
			render :new, status: :unprocessable_entity
		end
  	end

	def import_glossary
		if (params[:glossary_placeholder].present? && params[:glossary_placeholder][:file].present?)
		  import = Wordindex.import_glossary(params[:glossary_placeholder][:file],current_user.id)
		  if import[:status] == "true"
			redirect_to admin_wordindices_path, flash_success_info: "#{import[:records_count]} terms of glossary imported successfully"
		  else
			redirect_to admin_wordindices_path, flash_info: "Something went wrong, please try again later."
		  end
		else
		  redirect_to admin_wordindices_path, flash_info: "File not found."
		end
	end

	def export_as_excel
		respond_to do |format|
			@wordindices = Wordindex.all.order(word: :asc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
			@wordindices = @wordindices.data.list(@wordindices.facets.filtered_count, nil, nil)
			WordindexExportEmailJob.perform_later(@wordindices.data.to_a, current_user.email)
			format.html { redirect_back fallback_location: admin_wordindices_path, flash_success_info: "Glossary details was successfully exported will email you shortly." }
		end
	end

	private

	def secure_params
		params.require(:wordindex).permit(:word, :description)
	end

	def set_wordindex
		@wordindex = Wordindex.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search) if params[:filters]
  end

end
