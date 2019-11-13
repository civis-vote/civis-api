class UserExportEmailJob < ApplicationJob
  queue_as :default

  def perform(users, email)
    UserMailer.user_export_email_job(users, email).deliver_now
  end
end
