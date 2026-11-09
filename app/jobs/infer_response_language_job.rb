class InferResponseLanguageJob < ApplicationJob
  queue_as :default

  def perform(consultation_response)
    service = InferResponseLanguageService.new(consultation_response)
    service.call
  rescue StandardError => e
    Airbrake.notify(e)
    raise e
  end
end
