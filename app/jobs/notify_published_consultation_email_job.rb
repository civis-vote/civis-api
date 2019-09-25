class NotifyPublishedConsultationEmailJob < ApplicationJob
  queue_as :default

  def perform(consultation)
    UserMailer.notify_published_consultation_email(consultation).deliver_now
  end
end
