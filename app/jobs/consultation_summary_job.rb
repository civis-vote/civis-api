class ConsultationSummaryJob < ApplicationJob
  queue_as :default

  MAX_TRANSCRIPTION_RETRIES = 10
  RETRY_DELAY = 1.minute

  def perform(consultation, retry_count = 0)
    Rails.logger.info("ConsultationSummaryJob: Starting summarisation for Consultation #{consultation.id}")

    if pending_voice_transcriptions?(consultation) && retry_count < MAX_TRANSCRIPTION_RETRIES
      Rails.logger.info("ConsultationSummaryJob: Waiting for voice transcriptions for Consultation #{consultation.id} (attempt #{retry_count + 1})")
      self.class.set(wait: RETRY_DELAY).perform_later(consultation, retry_count + 1)
      return
    end

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

  private

  def pending_voice_transcriptions?(consultation)
    consultation.responses.acceptable.exists?(transcription_status: :pending)
  end
end
