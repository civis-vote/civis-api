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

  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      query GetConsultation($id: Int!) {
        consultationProfile(id: $id) {
          id
          feedbackSubmittedAt
          acknowledgedAt
          policyReleasedAt
          responseRounds { id roundNumber active questions { id questionText } }
          sharedResponses(sort: created_at, sortDirection: asc) { nodes { id } }
          satisfactionRatingDistribution
          enforcePrivateResponse
        }
      }
    GQL
  end

  let(:token_query) do
    <<~GQL
      query GetConsultationResponses($id: Int!, $responseToken: String!) {
        consultationProfile(id: $id, responseToken: $responseToken) {
          id
          responses(responseToken: $responseToken, sort: created_at, sortDirection: asc) { nodes { id } }
        }
      }
    GQL
  end

  let(:reader_query) do
    <<~GQL
      query GetConsultationForReader($id: Int!) {
        consultationProfile(id: $id) {
          id
          respondedOn
          hasUserFilledResponseInCurrentResponseRound
        }
      }
    GQL
  end

  let(:variables) { { id: consultation.id } }
  let(:result) { gql_execute(query, variables: variables, context: context) }
  let(:profile) { result.dig('data', 'consultationProfile') }

  describe 'timeline fields' do
    let(:context) { {} }

    it 'returns the timeline timestamps' do
      expect(profile['feedbackSubmittedAt']).to eq(consultation.feedback_submitted_at.utc.iso8601)
      expect(profile['acknowledgedAt']).to eq(consultation.acknowledged_at.utc.iso8601)
      expect(profile['policyReleasedAt']).to eq(consultation.policy_released_at.utc.iso8601)
    end

    it 'returns null when the timeline timestamps are not set' do
      consultation.update!(published_at: nil, feedback_submitted_at: nil, acknowledged_at: nil,
                           policy_released_at: nil)

      expect(profile['feedbackSubmittedAt']).to be_nil
      expect(profile['acknowledgedAt']).to be_nil
      expect(profile['policyReleasedAt']).to be_nil
    end
  end

  describe 'response rounds and questions' do
    let(:context) { {} }

    before do
      consultation.response_rounds.last.questions.create!(
        question_text: 'Do you support this policy?', question_type: :multiple_choice, is_optional: false
      )
    end

    it 'exposes the rounds with their questions' do
      round = profile['responseRounds'].first

      expect(round['roundNumber']).to eq(1)
      expect(round['active']).to be(true)
      expect(round['questions'].map { |q| q['questionText'] }).to eq(['Do you support this policy?'])
    end
  end

  describe 'shared responses' do
    let(:context) { {} }

    let!(:shared_response) do
      ConsultationResponse.create!(user: user, consultation: consultation,
                                   response_round: consultation.response_rounds.last,
                                   visibility: :shared, response_status: :acceptable,
                                   response_text: 'A shared response')
    end

    let!(:anonymous_response) do
      anonymous_author = User.create!(first_name: 'Quiet', last_name: 'User', email: Faker::Internet.unique.email,
                                      password: 'Password@123', role: :citizen, confirmed_at: Time.current)
      ConsultationResponse.create!(user: anonymous_author, consultation: consultation,
                                   response_round: consultation.response_rounds.last,
                                   visibility: :anonymous, response_status: :acceptable,
                                   response_text: 'An anonymous response')
    end

    it 'lists shared responses only' do
      ids = profile.dig('sharedResponses', 'nodes').map { |r| r['id'].to_i }

      expect(ids).to eq([shared_response.id])
    end

    it 'shows the satisfaction rating distribution' do
      expect(profile['satisfactionRatingDistribution']).to eq(nil => 0)
    end
  end

  describe 'for the signed-in reader' do
    let(:context) { { current_user: user } }
    let(:result) { gql_execute(reader_query, variables: variables, context: context) }
    let(:profile) { result.dig('data', 'consultationProfile') }

    it 'shows when the reader responded and whether they already filled this round' do
      response = ConsultationResponse.create!(user: user, consultation: consultation,
                                              response_round: consultation.response_rounds.last,
                                              visibility: :shared, response_status: :acceptable,
                                              response_text: 'My response')

      expect(profile['respondedOn']).to eq(response.created_at.utc.iso8601)
      expect(profile['hasUserFilledResponseInCurrentResponseRound']).to be(true)
    end

    it 'shows nothing when the reader has not responded' do
      expect(profile['respondedOn']).to be_nil
      expect(profile['hasUserFilledResponseInCurrentResponseRound']).to be(false)
    end
  end

  describe 'responses gated by the response token' do
    let(:context) { {} }

    let!(:acceptable_response) do
      ConsultationResponse.create!(user: user, consultation: consultation,
                                   response_round: consultation.response_rounds.last,
                                   visibility: :shared, response_status: :acceptable,
                                   response_text: 'A published response')
    end

    it 'lists acceptable responses for the right token' do
      result = gql_execute(token_query, variables: { id: consultation.id, responseToken: consultation.response_token },
                                        context: {})
      ids = result.dig('data', 'consultationProfile', 'responses', 'nodes').map { |r| r['id'].to_i }

      expect(ids).to eq([acceptable_response.id])
    end

    it 'rejects a wrong token' do
      result = gql_execute(token_query, variables: { id: consultation.id, responseToken: 'wrong-token' }, context: {})

      expect(result.dig('data', 'consultationProfile', 'responses')).to be_nil
      expect(result['errors'].first['message']).to eq('User is not authorized to perform this action')
    end
  end

  describe 'private response enforcement' do
    let(:context) { {} }

    it 'reflects the consultation flag' do
      consultation.update!(private_response: 1)

      expect(profile['enforcePrivateResponse']).to be(true)
    end

    it 'is off by default' do
      expect(profile['enforcePrivateResponse']).to be(false)
    end
  end
end
