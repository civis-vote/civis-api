require 'rails_helper'

RSpec.describe Queries::Location::Autocomplete, type: :graphql do
  let!(:indian_city) { Location.create!(name: "Mumbai #{SecureRandom.hex(4)}", location_type: :city) }
  let!(:other_city) { Location.create!(name: "Chennai #{SecureRandom.hex(4)}", location_type: :city) }
  let!(:international_city) do
    Location.create!(name: "Mumbai #{SecureRandom.hex(4)} Global", location_type: :city, is_international_city: true)
  end

  let(:query) do
    <<~GQL
      query AutocompleteLocations($q: String, $type: String, $isInternationalCity: Boolean) {
        locationAutocomplete(q: $q, type: $type, isInternationalCity: $isInternationalCity) {
          id
          name
        }
      }
    GQL
  end

  let(:result) { gql_execute(query, variables: { q: 'mumbai' }, context: {}) }
  let(:names) { result.dig('data', 'locationAutocomplete').map { |l| l['name'] } }

  it 'searches by name across all location kinds when untyped' do
    expect(names).to include(indian_city.name, international_city.name)
    expect(names).not_to include(other_city.name)
  end

  it 'excludes international cities once a type is given' do
    result = gql_execute(query, variables: { q: 'mumbai', type: 'city' }, context: {})

    names = result.dig('data', 'locationAutocomplete').map { |l| l['name'] }
    expect(names).to include(indian_city.name)
    expect(names).not_to include(international_city.name)
  end

  it 'respects the type filter' do
    result = gql_execute(query, variables: { q: 'mumbai', type: 'state' }, context: {})

    expect(result.dig('data', 'locationAutocomplete')).to be_empty
  end
end
