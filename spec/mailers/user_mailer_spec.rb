require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '#notify_expired_consultation_email' do
    let(:department) do
      Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                         department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
    end

    let(:consultation) do
      Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}",
                           department: department,
                           response_deadline: 1.day.from_now,
                           question_flow: :question_list,
                           consultation_feedback_email: 'feedback@test.com')
    end

    before do
      allow(consultation).to receive(:created_by).and_return(instance_double(User, first_name: 'Officer'))
      allow_any_instance_of(Postmark::ApiClient)
        .to receive(:deliver_with_template).and_return({ message_id: 'postmark-msg-1' })
    end

    it 'stores the Postmark message id and creates a linked CmEmailLog' do
      expect do
        described_class.notify_expired_consultation_email('officer@gov.in', consultation, 'Officer', 'Secretary').deliver_now
      end.to change(CmEmailLog, :count).by(1)

      email_log = CmEmailLog.last
      expect(email_log.message_id).to eq('postmark-msg-1')
      expect(email_log.record).to eq(consultation)
      expect(email_log.module_name).to eq('Consultation')
      expect(email_log.recipients.first.email).to eq('officer@gov.in')
      expect(email_log.recipients.first.status).to eq('processed')
      expect(consultation.reload.feedback_email_message_id).to eq('postmark-msg-1')
    end
  end
end
