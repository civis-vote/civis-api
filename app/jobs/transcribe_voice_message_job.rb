class TranscribeVoiceMessageJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  def perform(consultation_response_id, attachment_id)
    VoiceMessageTranscriptionProcessor.new(consultation_response_id, attachment_id).call
  end
end
