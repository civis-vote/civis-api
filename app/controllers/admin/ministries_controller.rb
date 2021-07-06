class Admin::MinistriesController < ApplicationController
	layout "admin_panel_sidenav"
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show, :approve, :reject, :destroy, :create]
	before_action :set_ministry, only: [:edit, :update, :show, :approve, :reject, :destroy]

	def index
    @ministries = Ministry.all.includes(:created_by).order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: "admin/ministries/table", locals: { ministries: @ministries } }
      else
        format.html
      end
    end
	end

	def show
	end

	def update
		@location_id = params[:ministry][:location_id]
		@ministry_level = params[:ministry][:level]

		if @location_id.blank?
			params[:ministry][:location_id] = 0
		else
			@location_type = Location.find(@location_id).location_type
			if @ministry_level == "national"
				flash[:flash_info] = "Location cannot be selected for national level Ministry."
				redirect_to admin_ministry_path(@ministry) and return
			else
				if @ministry_level == "state" and @location_type != "state"
					flash[:flash_info] = "Location is not a state for State level Ministry."
					redirect_to admin_ministry_path(@ministry) and return
				else
					if @ministry_level == "local" and @location_type != "city"
						flash[:flash_info] = "Location is not a city for Local level Ministry."
						redirect_to admin_ministry_path(@ministry) and return
					end
				end
			end
		end
		
		if @ministry.update(secure_params)
			redirect_to admin_ministry_path(@ministry), flash_success_info: "Ministry details was successfully updated."
		else
			redirect_back fallback_location: root_path, flash_info: "Ministry details was not successfully updated."
		end
	end

	def destroy
		@ministry.destroy
		redirect_to admin_ministries_path, flash_success_info: "Ministry was successfully deleted."
	end

	def new
		@ministry = Ministry.new
	end

	def create
		@ministry = Ministry.new(secure_params.merge(created_by_id: current_user.id))
		
		if @ministry.location_id.nil?
			@ministry.location_id = 0
		else
			@location_type = Location.find(@ministry.location_id).location_type
			if @ministry.level == "national"
				flash[:flash_info] = "Location cannot be selected for national level Ministry."
				redirect_to admin_ministries_path and return
			else
				if @ministry.level == "state" and @location_type != "state"
					flash[:flash_info] = "Location is not a state for State level Ministry."
					redirect_to admin_ministries_path and return
				else
					if @ministry.level == "local" and @location_type != "city"
						flash[:flash_info] = "Location is not a city for Local level Ministry."
						redirect_to admin_ministries_path and return
					end
				end
			end
		end

		if @ministry.save
		  redirect_to admin_ministry_path(@ministry), flash_success_info: "Ministry was successfully created."
		else
			flash[:flash_info] = "Ministry was not successfully created."
		  render :new
		end
	end

	def approve
		@ministry.approve
		redirect_back fallback_location: root_path,  flash_success_info: "Ministry was successfully approved."
	end

	def reject
		@ministry.reject
		redirect_back fallback_location: root_path,  flash_success_info: "Ministry was successfully rejected."
	end

	private

	def secure_params
		params.require(:ministry).permit(:name, :level, :poc_email_primary, :poc_email_secondary, :logo, :category_id, :location_id)
	end

	def set_ministry
		@ministry = Ministry.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search, :status_filter) if params[:filters]
  end

end
