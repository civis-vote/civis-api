require 'rails_helper'

RSpec.describe Queries::Consultation::ResponseSummary, type: :graphql do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let(:consultation) do
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list)
  end

  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      query Summary($id: Int!) {
        consultationResponseSummary(id: $id) {
          totalResponses
          questions {
            questionText
            totalResponses
            optionBreakdown { optionText selectionCount percentage }
          }
        }
      }
    GQL
  end

  let(:variables) { { id: consultation.id } }
  let(:result) { gql_execute(query, variables: variables, context: {}) }
  let(:summary) { result.dig('data', 'consultationResponseSummary') }

  it 'returns nothing before the consultation expires' do
    expect(summary).to be_nil
  end

  describe 'once the consultation expires' do
    let(:support_question) do
      consultation.response_rounds.last.questions.create!(
        question_text: 'Do you support this policy?', question_type: :multiple_choice,
        is_optional: false, sub_questions_attributes: [{ question_text: 'Yes' }, { question_text: 'No' }]
      )
    end

    before do
      question = support_question
      ConsultationResponse.create!(user: user, consultation: consultation,
                                   response_round: consultation.response_rounds.last,
                                   visibility: :shared, response_status: :acceptable,
                                   answers: [{ 'question_id' => question.id.to_s,
                                               'answer' => [question.sub_questions.first.id] }])
      consultation.update_column(:response_deadline, 1.day.ago)
      consultation.expire
    end

    it 'aggregates the answers' do
      expect(summary['totalResponses']).to eq(1)

      support_summary = summary['questions'].find { |q| q['questionText'] == 'Do you support this policy?' }
      yes_breakdown = support_summary['optionBreakdown'].find { |o| o['optionText'] == 'Yes' }
      no_breakdown = support_summary['optionBreakdown'].find { |o| o['optionText'] == 'No' }
      expect(support_summary['totalResponses']).to eq(1)
      expect(yes_breakdown['selectionCount']).to eq(1)
      expect(yes_breakdown['percentage']).to eq(100.0)
      expect(no_breakdown['selectionCount']).to eq(0)
    end
  end
end
