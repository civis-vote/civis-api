class InviteOrganisationEmployeeJob < ApplicationJob
  queue_as :default

  def perform(user, url)
    UserMailer.invite_organisation_employee(user, url).deliver_now
  end
end
