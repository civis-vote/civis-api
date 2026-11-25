require 'rails_helper'

RSpec.describe Queries::GeoCountryCode, type: :graphql do
  let(:query) do
    <<~GQL
      query GeoCountryCode {
        geoCountryCode
      }
    GQL
  end

  let(:result) { gql_execute(query, context: {}) }

  it 'resolves the country code for the request IP' do
    allow(CmGeoIpNetwork).to receive(:geo_country_iso_code).and_return('IN')

    expect(result.dig('data', 'geoCountryCode')).to eq('IN')
  end
end
