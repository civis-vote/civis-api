require 'rails_helper'

RSpec.describe Mutations::ConsultationResponseVote::Delete, type: :graphql do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let(:consultation) do
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list)
  end

  let(:author) do
    User.create!(first_name: 'Author', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:voter) do
    User.create!(first_name: 'Voter', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:response) do
    ConsultationResponse.create!(user: author, consultation: consultation,
                                 response_round: consultation.response_rounds.last,
                                 visibility: :shared, response_status: :acceptable,
                                 response_text: 'A thoughtful response')
  end

  let(:query) do
    <<~GQL
      mutation Unvote($consultationResponseId: Int!) {
        voteDelete(consultationResponseId: $consultationResponseId)
      }
    GQL
  end

  let(:variables) { { consultationResponseId: response.id } }
  let(:result) { gql_execute(query, variables: variables, context: { current_user: voter }) }

  before do
    ConsultationResponseVote.create!(consultation_response: response, user: voter, vote_direction: :up)
  end

  it 'removes the vote and refreshes the counters' do
    expect(result.dig('data', 'voteDelete')).to be(true)
    expect(response.reload.up_vote_count).to eq(0)
    expect(voter.votes.count).to eq(0)
  end

  describe 'when the voter has not voted' do
    before { voter.votes.destroy_all }

    it 'errors instead of silently succeeding' do
      expect(result.dig('data', 'voteDelete')).to be_nil
      expect(result['errors']).not_to be_empty
    end
  end

  describe 'when nobody is signed in' do
    let(:result) { gql_execute(query, variables: variables, context: {}) }

    it 'rejects the request' do
      expect(result.dig('data', 'voteDelete')).to be_nil
      expect(result['errors']).not_to be_empty
    end
  end
end
