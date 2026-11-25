require 'rails_helper'

RSpec.describe ResponseRound, type: :model do
  let(:consultation) { create(:consultation) }

  it 'belongs to a consultation' do
    round = ResponseRound.create!(consultation:)

    expect(round.consultation).to eq(consultation)
  end

  it 'numbers rounds in creation order' do
    first_round = consultation.response_rounds.first

    second_round = ResponseRound.create!(consultation:)

    expect(first_round.round_number).to eq(1)
    expect(second_round.reload.round_number).to eq(2)
  end

  it 'exposes its questions and respondents' do
    round = consultation.response_rounds.first
    question = round.questions.create!(question_text: 'Any comments?', question_type: :long_text, is_optional: true)
    respondent = Respondent.create!(user: create(:user), response_round: round)

    expect(round.questions).to include(question)
    expect(round.respondents).to include(respondent)
  end
end
