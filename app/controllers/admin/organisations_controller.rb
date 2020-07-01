class Admin::OrganisationsController < ApplicationController
	layout "admin_panel_sidenav"
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show, :create]
	before_action :set_organisation, only: [:edit, :update, :show, :destroy]

	def index
    @organisations = Organisation.active.includes(:created_by).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: "admin/organisations/table", locals: {organisations: @organisations}}
      else
        format.html
      end
    end
	end

	def show
    @employees = @organisation.users.filter_by(params[:page], filter_params.to_h, sort_params.to_h)
	end

  def edit

  end

	def update
		if @organisation.update(secure_params)
			redirect_to admin_organisation_path(@organisation), flash_success_info: "Organisation details was successfully updated."
		else
			redirect_back fallback_location: root_path, flash_info: "Organisation details was not successfully updated."
		end
	end

	def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(secure_params.merge(created_by_id: current_user.id))
    if @organisation.save
      redirect_to admin_organisation_path(@organisation), flash_success_info: "Organisation was successfully created."
    else
    	flash[:flash_info] = "Organisation was not successfully created."
      render :new
    end
  end

	def destroy
		@organisation.deactivate
		redirect_to admin_organisations_path, flash_success_info: "Organisation was successfully deleted."
	end

	def secure_params
		params.require(:organisation).permit(:name, :logo, :email)
	end

	def set_organisation
		@organisation = Organisation.find(params[:id])
	end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search_query) if params[:filters]
  end
end
