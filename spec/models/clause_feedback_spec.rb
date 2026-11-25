require 'rails_helper'

RSpec.describe ClauseFeedback, type: :model do
  let(:consultation) { create(:consultation) }
  let(:clause) { Clause.create!(consultation:, clause_id: '3.1', clause_title: 'Definitions') }
  let(:response) { create(:consultation_response, consultation:) }

  it 'belongs to a clause and a consultation response' do
    feedback = ClauseFeedback.create!(clause:, consultation_response: response,
                                      feedback_comment: 'Unclear wording')

    expect(feedback.clause).to eq(clause)
    expect(feedback.consultation_response).to eq(response)
    expect(feedback.consultation).to eq(consultation)
  end

  it 'stores rich text comments' do
    feedback = ClauseFeedback.create!(clause:, consultation_response: response,
                                      feedback_comment: 'Unclear wording')

    expect(feedback.feedback_comment.to_plain_text).to eq('Unclear wording')
  end
end
