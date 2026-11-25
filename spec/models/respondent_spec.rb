require 'rails_helper'

RSpec.describe Respondent, type: :model do
  let(:consultation) { create(:consultation) }
  let(:response_round) { consultation.response_rounds.last }
  let(:user) { create(:user, first_name: 'Asha', last_name: 'Rao') }

  it 'belongs to a user and a response round' do
    respondent = Respondent.create!(user:, response_round:)

    expect(respondent.user).to eq(user)
    expect(respondent.response_round).to eq(response_round)
  end

  describe '.search_user_query' do
    let!(:respondent) { Respondent.create!(user:, response_round:) }

    it 'finds respondents by first name' do
      expect(Respondent.search_user_query('asha')).to include(respondent)
    end

    it 'finds respondents by email' do
      expect(Respondent.search_user_query(user.email)).to include(respondent)
    end

    it 'requires every term to match' do
      expect(Respondent.search_user_query('asha nomatch')).to be_empty
    end

    it 'returns everything without a query' do
      expect(Respondent.search_user_query(nil)).to include(respondent)
    end
  end
end
