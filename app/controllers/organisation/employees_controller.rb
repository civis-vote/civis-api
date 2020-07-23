class Organisation::EmployeesController < Organisation::SettingsController
  layout "organisation_sidenav"
  before_action :authenticate_user!
  before_action :require_organisation_employee, only: [:invite, :list_employees, :deactivate, :details, :edit_employee]
	before_action :set_organisation, only: [:invite, :list_employees, :deactivate, :details, :edit_employee]
  before_action :set_user, only: [:details, :edit_employee]

  def details
    
  end

  def edit_employee
    if @user.update(secure_user_params)
      redirect_to organisation_setting_path(@organisation), flash_success_info: "Employee details was successfully updated."
    else
      redirect_back fallback_location: root_path, flash_info: "Employee details was not successfully updated."
    end
  end

  def list_employees
    @user = @organisation.users.build
    @employees = @organisation.users.filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: "organisation/settings/employees_table", locals: {employees: @employees}}
      else
        format.html 
      end
    end
  end

  def invite
    user = User.invite_employee(secure_user_params, current_user)
    if user
      redirect_to list_employees_organisation_setting_path(@organisation), flash_success_info: "Employees was successfully invited."
    else
      redirect_to list_employees_organisation_setting_path(@organisation), flash_info: "Employees was not successfully invited."
    end
  end

  def deactivate
    employee = @organisation.users.find_by(id: params[:user_id])
    employee.deactivate(@organisation.id)
    redirect_to list_employees_organisation_setting_path(@organisation), flash_success_info: "Employee was successfully deleted."
  end

	private

  def set_user
    @user = @organisation.users.find(params[:user_id])
  end

  def secure_user_params
    params.require(:user).permit(:email, :organisation_id, :active, :first_name, :last_name, :profile_picture)
  end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search_query) if params[:filters]
  end
end
