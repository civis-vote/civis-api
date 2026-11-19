# Postmark is configured to deliver consultation feedback events to the
# legacy /admin/consultations/feedback_webhook URL. Route those requests
# through the cm-admin Postmark pipeline so they are logged as
# CmWebhookEvent records and processed like /cm_admin/webhooks/postmark.
module Admin
  class ConsultationsFeedbackWebhookController < CmAdmin::PostmarkWebhooksController
    private

    # The legacy endpoint had no authentication and Postmark may not be
    # sending basic-auth credentials for this URL, so verify credentials
    # only when an Authorization header is present.
    def authenticate_webhook
      super if request.authorization.present?
    end
  end
end
