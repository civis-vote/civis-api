require 'rails_helper'

RSpec.describe GlossaryWordConsultationMapping, type: :model do
  let(:consultation) { create(:consultation) }
  let(:wordindex) { create(:wordindex, word: 'Federalism') }

  it 'maps a glossary word to a consultation' do
    mapping = GlossaryWordConsultationMapping.create!(consultation:, glossary: wordindex)

    expect(mapping.consultation).to eq(consultation)
    expect(mapping.glossary).to eq(wordindex)
    expect(mapping.consultation_title).to eq(consultation.title)
    expect(mapping.glossary_word).to eq('Federalism')
  end

  it 'needs a consultation and a glossary word' do
    expect(GlossaryWordConsultationMapping.new).not_to be_valid
  end

  # Documents a gap: the search scope binds 2 values to 1 placeholder, so it always raises.
  describe '.search' do
    it 'raises a bind error because the scope passes too many bind values' do
      GlossaryWordConsultationMapping.create!(consultation:, glossary: wordindex)

      expect { GlossaryWordConsultationMapping.search(consultation.id.to_s) }
        .to raise_error(ActiveRecord::PreparedStatementInvalid)
    end
  end
end
