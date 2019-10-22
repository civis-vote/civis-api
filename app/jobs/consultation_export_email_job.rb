class ConsultationExportEmailJob < ApplicationJob
  queue_as :default

  def perform(consultations, email)
    UserMailer.consultation_export_email_job(consultations, email).deliver_now
  end
end
