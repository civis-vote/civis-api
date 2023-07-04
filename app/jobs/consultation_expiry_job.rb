class ConsultationExpiryJob < ApplicationJob
  queue_as :default

  def perform(consultation)
    consultation.expire if TZInfo::Timezone.get("Asia/Kolkata").local_to_utc(Time.parse(consultation.response_deadline.to_s)) < DateTime.now
  end
end
