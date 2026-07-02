class ExtractClausesJob < ApplicationJob
  queue_as :default

  def perform(consultation_id)
    consultation = Consultation.find_by(id: consultation_id)

    unless consultation
      Rails.logger.error("ExtractClausesJob: Consultation not found with ID #{consultation_id}")
      return
    end

    Rails.logger.info("ExtractClausesJob: Starting clause extraction for Consultation #{consultation.id}")

    service = ClauseExtractionService.new(consultation)
    result = service.call

    if result[:success]
      Rails.logger.info("ExtractClausesJob: Successfully extracted #{result[:clauses].size} clauses for Consultation #{consultation.id}")
    else
      Rails.logger.error("ExtractClausesJob: Failed to extract clauses for Consultation #{consultation.id}: #{result[:message]}")
    end

    result
  rescue StandardError => e
    Rails.logger.error("ExtractClausesJob: Unexpected error for Consultation #{consultation_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))

    { success: false, message: "Job failed: #{e.message}", errors: [e.message] }
  end
end
