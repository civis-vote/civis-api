require 'rails_helper'

RSpec.describe ConsultationResponseVote, type: :model do
  let(:consultation) { create(:consultation) }
  let(:response) { create(:consultation_response, consultation:, response_round: consultation.response_rounds.last) }
  let(:voter) { create(:user) }

  it 'belongs to a response and a voter' do
    vote = ConsultationResponseVote.create!(consultation_response: response, user: voter, vote_direction: :up)

    expect(vote.consultation_response).to eq(response)
    expect(vote.user).to eq(voter)
  end

  it 'allows one vote per user per response' do
    ConsultationResponseVote.create!(consultation_response: response, user: voter, vote_direction: :up)

    expect do
      ConsultationResponseVote.create!(consultation_response: response, user: voter, vote_direction: :down)
    end.to raise_error(ActiveRecord::RecordInvalid, /already been taken/)
  end

  it 'refreshes the response vote counters after commit' do
    ConsultationResponseVote.create!(consultation_response: response, user: voter, vote_direction: :up)

    expect(response.reload.up_vote_count).to eq(1)
    expect(response.down_vote_count).to eq(0)
  end
end
