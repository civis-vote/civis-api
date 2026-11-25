require 'rails_helper'

RSpec.describe Clause, type: :model do
  let(:consultation) { create(:consultation) }

  it 'belongs to a consultation' do
    clause = Clause.create!(consultation:, clause_id: '3.1', clause_title: 'Definitions')

    expect(clause.consultation).to eq(consultation)
    expect(clause.consultation_title).to eq(consultation.title)
  end

  it 'needs a clause id and title' do
    expect(Clause.new(consultation:)).not_to be_valid
  end

  it 'delegates the clause type name' do
    clause_type = Constant.create!(name: 'Taxation', constant_type: :clause_type)
    clause = Clause.create!(consultation:, clause_id: '3.1', clause_title: 'Definitions',
                            clause_type:)

    expect(clause.clause_type_name).to eq('Taxation')
  end

  it 'destroys its feedbacks when destroyed' do
    clause = Clause.create!(consultation:, clause_id: '3.1', clause_title: 'Definitions')
    response = create(:consultation_response, consultation:)
    ClauseFeedback.create!(clause:, consultation_response: response, feedback_comment: 'Unclear')

    expect { clause.destroy }.to change(ClauseFeedback, :count).by(-1)
  end
end
