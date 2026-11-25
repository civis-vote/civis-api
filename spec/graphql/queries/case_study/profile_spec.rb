require 'rails_helper'

RSpec.describe Queries::CaseStudy::Profile, type: :graphql do
  let!(:case_study) { create(:case_study, name: 'A case study') }

  let(:query) do
    <<~GQL
      query GetCaseStudy($id: Int!) {
        caseStudyProfile(id: $id) {
          id
          name
          ministryName
        }
      }
    GQL
  end

  let(:result) { gql_execute(query, variables: { id: case_study.id }, context: {}) }
  let(:profile) { result.dig('data', 'caseStudyProfile') }

  it 'returns the case study' do
    expect(profile['id'].to_i).to eq(case_study.id)
    expect(profile['name']).to eq('A case study')
    expect(profile['ministryName']).to eq('Ministry of Testing')
  end

  it 'errors for an unknown case study' do
    result = gql_execute(query, variables: { id: -1 }, context: {})

    expect(result.dig('data', 'caseStudyProfile')).to be_nil
    expect(result['errors']).not_to be_empty
  end
end
