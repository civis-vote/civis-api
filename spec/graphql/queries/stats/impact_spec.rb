require 'rails_helper'

RSpec.describe Queries::Stats::Impact, type: :graphql do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let(:query) do
    <<~GQL
      query ImpactStats {
        impactStats
      }
    GQL
  end

  let(:result) { gql_execute(query, context: {}) }
  let(:stats) { result.dig('data', 'impactStats') }

  before do
    consultation = Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                                        response_deadline: 10.days.from_now, question_flow: :question_list)
    consultation.update_column(:status, Consultation.statuses[:published])
    user = User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                        password: 'Password@123', role: :citizen, confirmed_at: Time.current)
    ConsultationResponse.create!(user: user, consultation: consultation,
                                 response_round: consultation.response_rounds.last,
                                 visibility: :shared, response_status: :acceptable)
  end

  it 'counts consultations, responses, distinct responders and users' do
    expect(stats[:consultation_count]).to eq(1)
    expect(stats[:consultation_response_count]).to eq(1)
    expect(stats[:consultation_response_distinct_users]).to eq(1)
    expect(stats[:total_registered_users]).to eq(1)
  end
end
