class NotifyNewConsultationEmailJob < ApplicationJob
  queue_as :default

  def perform(consultation)
  	::User.notify_for_new_consultation_filter.each do |user|
      begin
    	 UserMailer.notify_new_consultation_email(user, consultation).deliver_now
      rescue
        puts "Failed to deliver email for User - #{user.id}"
      end
    end
  end
end
