require 'rails_helper'

RSpec.describe Mutations::ConsultationResponseVote::Create, type: :graphql do
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

  let!(:response) do
    ConsultationResponse.create!(user: author, consultation: consultation,
                                 response_round: consultation.response_rounds.last,
                                 visibility: :shared, response_status: :acceptable,
                                 response_text: 'A thoughtful response')
  end

  let(:query) do
    <<~GQL
      mutation Vote($vote: VoteCreateInput!) {
        voteCreate(consultationResponseVote: $vote) { id voteDirection }
      }
    GQL
  end

  let(:variables) { { vote: { consultationResponseId: response.id, voteDirection: 'up' } } }
  let(:result) { gql_execute(query, variables: variables, context: { current_user: voter }) }
  let(:vote) { result.dig('data', 'voteCreate') }

  it 'records the vote and refreshes the response counters' do
    expect(result['errors']).to be_nil
    expect(vote['voteDirection']).to eq('up')

    expect(response.reload.up_vote_count).to eq(1)
    expect(response.down_vote_count).to eq(0)
    expect(voter.votes.count).to eq(1)
  end

  it 'counts down-votes separately' do
    gql_execute(query, variables: { vote: { consultationResponseId: response.id, voteDirection: 'down' } },
                       context: { current_user: voter })

    expect(response.reload.down_vote_count).to eq(1)
    expect(response.up_vote_count).to eq(0)
  end

  describe 'when nobody is signed in' do
    let(:result) { gql_execute(query, variables: variables, context: {}) }

    it 'rejects the vote' do
      expect(vote).to be_nil
      expect(result['errors']).not_to be_empty
    end
  end
end
