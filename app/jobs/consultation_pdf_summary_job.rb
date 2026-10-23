class ConsultationPdfSummaryJob < ApplicationJob
  queue_as :default

  def perform(consultation)
    service = ConsultationPdfSummaryService.new(consultation)
    service.call
  rescue StandardError => e
    Airbrake.notify(e)
    raise e
  end
end
