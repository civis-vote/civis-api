class NotifyExpiredConsultationEmailJob < ApplicationJob
  queue_as :default

  def perform(email, consultation)
  	UserMailer.notify_expired_consultation_email(email, consultation).deliver_now
  end
end
