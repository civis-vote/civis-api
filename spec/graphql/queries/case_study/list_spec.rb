require 'rails_helper'

RSpec.describe Queries::CaseStudy::List, type: :graphql do
  let!(:case_study) { create(:case_study, name: "Waste management in Pune #{SecureRandom.hex(4)}") }
  let!(:other_case_study) { create(:case_study, name: "Water conservation #{SecureRandom.hex(4)}") }

  let(:query) do
    <<~GQL
      query ListCaseStudies($searchFilter: String, $page: Int, $perPage: Int) {
        caseStudyList(searchFilter: $searchFilter, page: $page, perPage: $perPage) {
          data { id name }
          paging { totalItems }
        }
      }
    GQL
  end

  let(:result) { gql_execute(query, variables: {}, context: {}) }
  let(:listed) { result.dig('data', 'caseStudyList') }

  it 'lists case studies' do
    ids = listed['data'].map { |c| c['id'].to_i }

    expect(ids).to contain_exactly(case_study.id, other_case_study.id)
    expect(listed['paging']['totalItems']).to eq(2)
  end

  it 'searches by name' do
    result = gql_execute(query, variables: { searchFilter: 'waste' }, context: {})
    ids = result.dig('data', 'caseStudyList', 'data').map { |c| c['id'].to_i }

    expect(ids).to eq([case_study.id])
  end
end
