class NotifyNewConsultationEmailToAdminJob < ApplicationJob
  queue_as :default

  def perform(consultation)
  	::User.where(role: [:admin, :moderator]).each do |user|
      begin
    	 UserMailer.notify_new_consultation_email_to_admin(user, consultation).deliver_now
      rescue
        puts "Failed to deliver email for User - #{user.id}"
      end
    end
  end
end
