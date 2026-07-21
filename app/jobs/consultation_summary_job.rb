class ConsultationSummaryJob < ApplicationJob
  queue_as :default

  def perform(consultation)
    Rails.logger.info("ConsultationSummaryJob: Starting summarisation for Consultation #{consultation.id}")

    service = ConsultationSummaryService.new(consultation)
    result = service.call

    if result[:success]
      Rails.logger.info("ConsultationSummaryJob: Successfully generated summary for Consultation #{consultation.id}")
    else
      Rails.logger.error("ConsultationSummaryJob: Failed to generate summary for Consultation #{consultation.id}: #{result[:message]}")
    end

    result
  rescue StandardError => e
    Rails.logger.error("ConsultationSummaryJob: Unexpected error for Consultation #{consultation.id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))

    { success: false, message: "Job failed: #{e.message}", errors: [e.message] }
  end
end
