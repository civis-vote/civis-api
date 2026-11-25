require 'rails_helper'

RSpec.describe Queries::Glossary::List, type: :graphql do
  let(:admin) do
    User.create!(first_name: 'Admin', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :admin, confirmed_at: Time.current)
  end

  before { Current.user = admin }
  after { Current.reset }

  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let(:consultation) do
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list)
  end

  let!(:mapping) do
    wordindex = Wordindex.create!(word: "Word #{SecureRandom.hex(4)}", description: 'A glossary word')
    GlossaryWordConsultationMapping.create!(consultation: consultation, glossary: wordindex)
  end

  let(:query) do
    <<~GQL
      query ListGlossary($page: Int, $perPage: Int) {
        glossaryList(page: $page, perPage: $perPage, sort: word, sortDirection: asc) {
          data { id consultationId }
          paging { totalItems }
        }
      }
    GQL
  end

  let(:result) { gql_execute(query, variables: {}, context: {}) }

  # Documents a gap: GlossaryWordConsultationMapping does not include Paginator,
  # so the resolver's `.list` call always fails. Fix the model, then assert the listing.
  it 'errors because the resolver calls a missing Paginator#list' do
    expect(result.dig('data', 'glossaryList')).to be_nil
    expect(result['errors'].first['message']).to include("undefined method 'list'")
  end
end
