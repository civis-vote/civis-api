require 'rails_helper'

RSpec.describe Queries::Consultation::Profile, type: :graphql do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let(:consultation) do
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list,
                         published_at: 5.days.ago, feedback_submitted_at: 1.day.ago,
                         acknowledged_at: 20.hours.ago, policy_released_at: 10.hours.ago)
  end

  let(:query) do
    <<~GQL
      query GetConsultation($id: Int!) {
        consultationProfile(id: $id) {
          id
          publishedDeadline
          feedbackSubmittedAt
          acknowledgedAt
          policyReleasedAt
        }
      }
    GQL
  end

  let(:variables) { { id: consultation.id } }
  let(:result) { CivisApiSchema.execute(query, variables: variables, context: {}) }
  let(:profile) { result.dig('data', 'consultationProfile') }

  describe 'timeline fields' do
    it 'returns the timeline timestamps' do
      expect(profile['publishedDeadline']).to eq(consultation.published_at.utc.iso8601)
      expect(profile['feedbackSubmittedAt']).to eq(consultation.feedback_submitted_at.utc.iso8601)
      expect(profile['acknowledgedAt']).to eq(consultation.acknowledged_at.utc.iso8601)
      expect(profile['policyReleasedAt']).to eq(consultation.policy_released_at.utc.iso8601)
    end

    it 'returns null when the timeline timestamps are not set' do
      consultation.update!(published_at: nil, feedback_submitted_at: nil, acknowledged_at: nil,
                           policy_released_at: nil)

      expect(profile['publishedDeadline']).to be_nil
      expect(profile['feedbackSubmittedAt']).to be_nil
      expect(profile['acknowledgedAt']).to be_nil
      expect(profile['policyReleasedAt']).to be_nil
    end
  end
end
