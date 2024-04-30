class Admin::ProfanitiesController < ApplicationController
	layout "admin_panel_sidenav"
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show, :destroy]
	before_action :set_profanity, only: [:edit, :update, :show, :destroy]

	def index
		@profanities = Profanity.all.includes(:created_by).order(profane_word: :asc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
		respond_to do |format|
			if request.xhr?
				format.html {render partial: "admin/profanities/table", locals: { profanities: @profanities } }
			else
				format.html
			end
	    end
	end

	def show
	end

	def update
		if @profanity.update(secure_params)
			redirect_to admin_profanity_path(@profanity), flash_success_info: "Profane word was successfully updated."
		else
			redirect_back fallback_location: root_path, flash_info: "Profane word was not successfully updated."
		end
	end

	def destroy
		@profanity.destroy
		redirect_to admin_profanities_path, flash_success_info: "Profane word was successfully deleted."
	end

	def new
		@profanity = Profanity.new
	end

	def create
		@profanity = Profanity.new(secure_params.merge(created_by: current_user))
		if Profanity.where(profane_word: secure_params[:profane_word]).empty?
			if @profanity.save 
				redirect_to admin_profanity_path(@profanity), flash_success_info: "Profane word was successfully created."
			else
				flash[:flash_info] = "Profane word was not successfully created."
			render :new, status: :unprocessable_entity
			end
		else
			flash[:flash_info] = "Profane word is already present and duplicate profane words cannot be inserted. Please Update the profane word instead."
			render :new, status: :unprocessable_entity
		end
  	end

	def import_profanities
		if (params[:profanities_placeholder].present? && params[:profanities_placeholder][:file].present?)
		  import = Profanity.import_profanities(params[:profanities_placeholder][:file],current_user.id)
		  if import[:status] == "true"
			redirect_to admin_profanities_path, flash_success_info: "#{import[:records_count]} profanities imported successfully"
		  else
			redirect_to admin_profanities_path, flash_info: "Something went wrong, please try again later."
		  end
		else
		  redirect_to admin_profanities_path, flash_info: "File not found."
		end
	end

	def export_as_excel
		respond_to do |format|
			@profanities = Profanity.all.order(profane_word: :asc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
			@profanities = @profanities.data.list(@profanities.facets.filtered_count, nil, nil)
			ProfanityExportEmailJob.perform_later(@profanities.data.to_a, current_user.email)
			format.html { redirect_back fallback_location: admin_profanities_path, flash_success_info: "Profane Word details was successfully exported will email you shortly." }
		end
	end

	private

	def secure_params
		params.require(:profanity).permit(:profane_word)
	end

	def set_profanity
		@profanity = Profanity.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search_profane_word) if params[:filters]
  end

end
