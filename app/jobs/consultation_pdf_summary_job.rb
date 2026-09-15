class ConsultationPdfSummaryJob < ApplicationJob
  queue_as :default

  def perform(consultation)
    Rails.logger.info("ConsultationPdfSummaryJob: Starting PDF summarisation for Consultation #{consultation.id}")

    service = ConsultationPdfSummaryService.new(consultation)
    result = service.call

    if result[:success]
      Rails.logger.info("ConsultationPdfSummaryJob: Successfully generated PDF summary for Consultation #{consultation.id}")
    else
      Rails.logger.error("ConsultationPdfSummaryJob: Failed to generate PDF summary for Consultation #{consultation.id}: #{result[:message]}")
    end

    result
  rescue StandardError => e
    Rails.logger.error("ConsultationPdfSummaryJob: Unexpected error for Consultation #{consultation.id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))

    { success: false, message: "Job failed: #{e.message}", errors: [e.message] }
  end
end
