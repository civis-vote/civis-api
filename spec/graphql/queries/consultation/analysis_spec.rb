require 'rails_helper'

RSpec.describe Queries::Consultation::Analysis, type: :graphql do
  let(:query) do
    <<~GQL
      query Analysis($id: Int!) {
        consultationAnalysis(id: $id)
      }
    GQL
  end

  let(:result) { gql_execute(query, variables: { id: 1 }, context: {}) }

  it 'returns nothing — the resolver is a placeholder kept for schema compatibility' do
    expect(result.dig('data', 'consultationAnalysis')).to be_nil
  end
end
