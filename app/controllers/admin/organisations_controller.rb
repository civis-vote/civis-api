class Admin::OrganisationsController < ApplicationController
	layout "admin_panel_sidenav"
  before_action :authenticate_user!
	before_action :require_admin, only: [:index, :update, :edit, :show, :create]
	before_action :set_organisation, only: [:edit, :update, :show, :destroy, :invite_employee, :list_employees, :destroy_employee]

	def index
    @organisations = Organisation.all.includes(:created_by).order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: "admin/organisations/table", locals: {organisations: @organisations}}
      else
        format.html
      end
    end
	end

	def show
		@user = @organisation.users.build
    @employees = @organisation.users.order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
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
		@organisation.destroy
		redirect_to admin_organisations_path, flash_success_info: "Organisation was successfully deleted."
	end

  def list_employees
    @employees = @organisation.users.order(created_at: :desc).filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: "admin/organisations/employees_table", locals: {employees: @employees}}
      else
        redirect_to action: 'show' and return
      end
    end
  end

  def invite_employee
    user = User.invite_employee(secure_user_params, current_user)
    if user
      redirect_to admin_organisation_path(@organisation), flash_success_info: "Employees was successfully invited."
    else
      redirect_to admin_organisation_path(@organisation), flash_info: "Employees was not successfully invited."
    end
  end

  def destroy_employee
    @organisation.users.find_by(id: params[:user_id]).destroy
    redirect_to admin_organisations_path, flash_success_info: "Employee was successfully deleted."
  end

	private

	def secure_params
		params.require(:organisation).permit(:name, :logo, :email)
	end

  def secure_user_params
    params.require(:user).permit(:email, :organisation_id)
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
