require 'rails_helper'

RSpec.describe Consultation, type: :model do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  def create_consultation(attrs = {})
    Consultation.create!({
      title: "Consultation #{SecureRandom.hex(4)}",
      department: department,
      response_deadline: 1.day.from_now,
      question_flow: :question_list,
      consultation_feedback_email: 'feedback@test.com'
    }.merge(attrs))
  end

  # Responses cannot be created after the deadline passes, so move the deadline
  # into the past with update_column (bypasses the expiry job callbacks).
  def expire_after(consultation)
    consultation.update_column(:response_deadline, 1.day.ago)
    consultation.expire
  end

  def create_acceptable_response(consultation)
    ConsultationResponse.create!(consultation: consultation, response_round: consultation.response_rounds.first,
                                 visibility: :shared, response_status: :acceptable, response_text: 'My feedback')
  end

  describe 'timeline fields' do
    let(:consultation) { create_consultation }

    it 'persists feedback_submitted_at, acknowledged_at and policy_released_at' do
      timestamp = 2.days.ago
      consultation.update!(feedback_submitted_at: timestamp, acknowledged_at: timestamp,
                           policy_released_at: timestamp)

      expect(consultation.reload.feedback_submitted_at).to be_within(1.minute).of(timestamp)
      expect(consultation.reload.acknowledged_at).to be_within(1.minute).of(timestamp)
      expect(consultation.reload.policy_released_at).to be_within(1.minute).of(timestamp)
    end
  end

  describe '#expire' do
    context 'when there are acceptable responses and a feedback report email is sent' do
      it 'sets feedback_submitted_at to the current time' do
        consultation = create_consultation
        create_acceptable_response(consultation)

        expire_after(consultation)

        expect(consultation.reload.feedback_submitted_at).to be_within(1.minute).of(Time.current)
      end
    end

    context 'when there are no acceptable responses' do
      it 'does not set feedback_submitted_at' do
        consultation = create_consultation

        expire_after(consultation)

        expect(consultation.reload.feedback_submitted_at).to be_nil
      end
    end

    context 'when feedback_submitted_at has already been set' do
      it 'does not overwrite the manually edited value' do
        consultation = create_consultation
        create_acceptable_response(consultation)
        consultation.update!(feedback_submitted_at: 1.week.ago)

        expire_after(consultation)

        expect(consultation.reload.feedback_submitted_at).to be_within(1.minute).of(1.week.ago)
      end
    end
  end
end
