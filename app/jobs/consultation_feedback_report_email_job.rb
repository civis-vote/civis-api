class ConsultationFeedbackReportEmailJob < ApplicationJob
  queue_as :default

  def perform(email, consultation, officer_name = nil, officer_designation = nil)
  	UserMailer.notify_expired_consultation_email(email, consultation, officer_name, officer_designation).deliver_now
  end
end
