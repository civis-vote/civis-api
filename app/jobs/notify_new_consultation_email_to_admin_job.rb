class NotifyNewConsultationEmailToAdminJob < ApplicationJob
  queue_as :default

  def perform(consultation)
    ::User.cm_role_filter(['Admin', 'Moderator', 'Super Admin']).each do |user|
      UserMailer.notify_new_consultation_email_to_admin(user, consultation).deliver_now
    rescue StandardError
      puts "Failed to deliver email for User - #{user.id}"
    end
  end
end
