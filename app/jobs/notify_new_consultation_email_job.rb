class NotifyNewConsultationEmailJob < ApplicationJob
  queue_as :default

  def perform(consultation)
  	::User.notify_for_new_consultation_filter.each do |user|
    	UserMailer.notify_new_consultation_email(user, consultation).deliver_now
    end
  end
end
