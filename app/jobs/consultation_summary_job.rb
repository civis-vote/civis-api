class ConsultationSummaryJob < ApplicationJob
  queue_as :default

  def perform(consultation)
    service = ConsultationSummaryService.new(consultation)
    service.call
  rescue StandardError => e
    Airbrake.notify(e)
    { success: false, message: "Job failed: #{e.message}", errors: [e.message] }
  end
end
