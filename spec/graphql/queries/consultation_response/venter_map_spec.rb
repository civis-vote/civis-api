require 'rails_helper'

RSpec.describe Queries::ConsultationResponse::VenterMap, type: :graphql do
  let(:query) do
    <<~GQL
      query VenterMap {
        consultationResponseVenterMap
      }
    GQL
  end

  let(:result) { gql_execute(query, context: {}) }

  it 'returns nothing — the resolver is a placeholder kept for schema compatibility' do
    expect(result.dig('data', 'consultationResponseVenterMap')).to be_nil
  end
end
