class ConsultationResponsesExportEmailJob < ApplicationJob
  queue_as :default

  def perform(consultation_responses, email)
    UserMailer.consultation_responses_export_email_job(consultation_responses, email).deliver_now
  end
end
