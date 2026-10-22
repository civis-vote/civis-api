# Host-specific webhook processing, invoked from CmAdmin::CmWebhookEventHandler#perform_processing
# after the gem's own service-level processing (see perform_cm_processing).
#
# Handles Postmark Delivery/Open/Click events for the consultation feedback email,
# whose tracking lives on Consultation (feedback_email_*) rather than CmEmailLog.
module HostWebhookEventHandler
  extend ActiveSupport::Concern

  def perform_host_processing
    return unless postmark?

    consultation = Consultation.find_by(feedback_email_message_id: payload['MessageID'])
    return if consultation.blank? || payload['Recipient'] == 'support@civis.vote'

    case payload['RecordType']
    when 'Delivery'
      consultation.update_columns(feedback_email_delivered_at: payload['DeliveredAt'])
    when 'Open'
      consultation.update_columns(feedback_email_opened_at: Time.current)
    when 'Click'
      consultation.update_columns(feedback_email_clicked_at: Time.current)
    end
  end
end
