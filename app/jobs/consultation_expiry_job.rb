class ConsultationExpiryJob < ApplicationJob
  queue_as :default

  def perform(consultation)
    consultation.expire if consultation.response_deadline < Time.current
  end
end
