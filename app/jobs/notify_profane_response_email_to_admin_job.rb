class NotifyProfaneResponseEmailToAdminJob < ApplicationJob
  queue_as :default

  def perform(consultation_response)
    ::User.cm_role_filter(%w[Admin]).each do |user|
      UserMailer.notify_profane_response_email_to_admin(user, consultation_response).deliver_now
    rescue StandardError
      puts "Failed to deliver email for User - #{user.id}"
    end
  end
end
