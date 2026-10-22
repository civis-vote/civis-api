require 'rails_helper'

RSpec.describe 'Postmark consultation feedback webhook', type: :request do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let!(:consultation) do
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}",
                         department: department,
                         response_deadline: 1.day.from_now,
                         question_flow: :question_list,
                         consultation_feedback_email: 'feedback@test.com',
                         feedback_email_message_id: 'message-123')
  end

  let(:auth_headers) do
    { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('hook', 'secret') }
  end

  before do
    allow(Rails.application.credentials).to receive(:dig).and_call_original
    allow(Rails.application.credentials).to receive(:dig).with(:postmark, :webhook_username).and_return('hook')
    allow(Rails.application.credentials).to receive(:dig).with(:postmark, :webhook_password).and_return('secret')
  end

  it 'rejects requests without basic auth credentials' do
    post '/cm_admin/webhooks/postmark',
         params: { 'RecordType' => 'Delivery', 'MessageID' => 'message-123' }, as: :json

    expect(response).to have_http_status(:unauthorized)
  end

  it 'logs a CmWebhookEvent and processes consultation timestamps' do
    expect do
      post '/cm_admin/webhooks/postmark',
           params: { 'RecordType' => 'Delivery', 'MessageID' => 'message-123',
                     'Recipient' => 'officer@gov.in', 'DeliveredAt' => '2026-10-21T10:00:00Z' },
           headers: auth_headers, as: :json
    end.to change(CmWebhookEvent, :count).by(1)

    expect(response).to have_http_status(:ok)

    event = CmWebhookEvent.last
    expect(event).to be_postmark
    expect(event.event_type).to eq('Delivery')
    expect(event.event_id).to eq('message-123')
    expect(event).to be_received

    event.process!
    expect(consultation.reload.feedback_email_delivered_at).to eq('2026-10-21T10:00:00Z')
    expect(event.reload).to be_processed
  end

  it 'records the opened timestamp on Open events' do
    post '/cm_admin/webhooks/postmark',
         params: { 'RecordType' => 'Open', 'MessageID' => 'message-123', 'Recipient' => 'officer@gov.in' },
         headers: auth_headers, as: :json
    CmWebhookEvent.last.process!

    expect(consultation.reload.feedback_email_opened_at).to be_present
  end

  it 'records the clicked timestamp on Click events' do
    post '/cm_admin/webhooks/postmark',
         params: { 'RecordType' => 'Click', 'MessageID' => 'message-123', 'Recipient' => 'officer@gov.in' },
         headers: auth_headers, as: :json
    CmWebhookEvent.last.process!

    expect(consultation.reload.feedback_email_clicked_at).to be_present
  end

  it 'ignores events for the support address' do
    post '/cm_admin/webhooks/postmark',
         params: { 'RecordType' => 'Delivery', 'MessageID' => 'message-123',
                   'Recipient' => 'support@civis.vote', 'DeliveredAt' => '2026-10-21T10:00:00Z' },
         headers: auth_headers, as: :json
    CmWebhookEvent.last.process!

    expect(consultation.reload.feedback_email_delivered_at).to be_nil
  end

  it 'marks the event processed even with no matching consultation' do
    post '/cm_admin/webhooks/postmark',
         params: { 'RecordType' => 'Delivery', 'MessageID' => 'unknown-id',
                   'Recipient' => 'officer@gov.in', 'DeliveredAt' => '2026-10-21T10:00:00Z' },
         headers: auth_headers, as: :json

    event = CmWebhookEvent.last
    event.process!

    expect(event.reload).to be_processed
  end
end
