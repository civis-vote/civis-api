require 'rails_helper'

RSpec.describe Queries::Glossary::Profile, type: :graphql do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let(:admin) do
    User.create!(first_name: 'Admin', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :admin, confirmed_at: Time.current)
  end

  before { Current.user = admin }
  after { Current.reset }

  let(:consultation) do
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list)
  end

  let(:other_consultation) do
    Consultation.create!(title: "Other #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list)
  end

  let!(:mapping) do
    wordindex = Wordindex.create!(word: "Word #{SecureRandom.hex(4)}", description: 'A glossary word')
    GlossaryWordConsultationMapping.create!(consultation: consultation, glossary: wordindex)
  end

  let!(:other_mapping) do
    wordindex = Wordindex.create!(word: "Other #{SecureRandom.hex(4)}", description: 'Another word')
    GlossaryWordConsultationMapping.create!(consultation: other_consultation, glossary: wordindex)
  end

  let(:query) do
    <<~GQL
      query GlossaryForConsultation($id: Int!) {
        glossaryWord(id: $id) {
          id
          consultationId
          wordindex { word description }
        }
      }
    GQL
  end

  let(:result) { gql_execute(query, variables: { id: consultation.id }, context: {}) }
  let(:mappings) { result.dig('data', 'glossaryWord') }

  it 'returns the glossary words of the consultation' do
    ids = mappings.map { |m| m['id'].to_i }

    expect(ids).to contain_exactly(mapping.id)
    expect(mappings.first['wordindex']['word']).to eq(mapping.glossary.word)
  end
end
