class UsersController < ApplicationController
	def edit_invite
    @user = User.find_by_invitation_token(params[:invitation_token], true)
    redirect_to root_path unless @user.present?
  end

  def accepting_invite
    user = User.accept_invitation!(secure_params)
    user.user_companies.first.update(approved: true) if user.user_companies.present?
    user.user_colleges.first.update(status: 'active') if (user.user_colleges.present? && user.user_colleges.first.invitation_pending?)
    if user.private_menternships.present?
      private_menternship_challenge = user.private_menternships.first.challenge
      redirect_url = request.headers['origin'] + "#{challenge_path(private_menternship_challenge)}"
      InvitePrivateMenternshipJob.perform_later(user.email, nil, private_menternship_challenge, redirect_url)
    end
    respond_to do |format|
      sign_in(user)
      if user.private_menternships.present?
        format.html { redirect_to root_path }
      elsif user.user_companies.present?
        format.html { redirect_to my_users_company_dashboard_users_path }
      elsif user.team.present? && user.team.subscriptions.present?
        format.html { redirect_to challenge_path(user.team.subscriptions.first.challenge_id) }
      elsif user.college_as_admin.first.present?
        format.html { redirect_to college_dashboard_dashboard_path }
      elsif user.aicte_as_admin.first.present?
        format.html { redirect_to college_dashboard_menternships_path(type: "hackathon") }
      else
        format.html { redirect_back fallback_location: root_path }
      end
    end
  end

  private

  def secure_params
    params.require(:user).permit(:admin, :is_mentor, :profile_picture, :first_name, :last_name,:sex, :age, :email, :mobile, :address, :line_1, :line_2, :area, :city, :state,:pincode, :dob, :interest, :industry_id, :job_function_id, :company_id, :college_id, :other_college, :invitation_token, :password, :created_via, :skipped_on_boarding)
  end
end