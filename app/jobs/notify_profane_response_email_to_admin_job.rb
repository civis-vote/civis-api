class NotifyProfaneResponseEmailToAdminJob < ApplicationJob
  queue_as :default

  def perform(consultation_response)
  	::User.where(role: [:admin]).each do |user|
      begin
    	 UserMailer.notify_profane_response_email_to_admin(user, consultation_response).deliver_now
      rescue
        puts "Failed to deliver email for User - #{user.id}"
      end
    end
  end
end
