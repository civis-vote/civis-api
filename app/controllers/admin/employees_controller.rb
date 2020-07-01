class Admin::EmployeesController < Admin::OrganisationsController
	before_action :set_organisation, only: [:invite, :list_employees, :deactivate]

  def list_employees
    @user = @organisation.users.build
    @employees = @organisation.users.filter_by(params[:page], filter_params.to_h, sort_params.to_h)
    respond_to do |format|
      if request.xhr?
        format.html {render partial: "admin/organisations/employees_table", locals: {employees: @employees}}
      else
        format.html 
      end
    end
  end

  def invite
    user = User.invite_employee(secure_user_params, current_user)
    if user
      redirect_to list_employees_admin_organisation_path(@organisation), flash_success_info: "Employees was successfully invited."
    else
      redirect_to list_employees_admin_organisation_path(@organisation), flash_info: "Employees was not successfully invited."
    end
  end

  def deactivate
    employee = @organisation.users.find_by(id: params[:user_id])
    employee.deactivate(@organisation.id)
    redirect_to admin_organisation_path(@organisation), flash_success_info: "Employee was successfully deleted."
  end

	private

  def secure_user_params
    params.require(:user).permit(:email, :organisation_id, :active)
  end

  def sort_params
    params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
  end

  def filter_params
    params.require(:filters).permit(:search_query) if params[:filters]
  end
end
