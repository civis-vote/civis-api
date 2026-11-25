require 'rails_helper'

RSpec.describe Queries::Location::List, type: :graphql do
  let!(:indian_city) { Location.create!(name: "Indian City #{SecureRandom.hex(4)}", location_type: :city) }
  let!(:international_city) do
    Location.create!(name: "Global City #{SecureRandom.hex(4)}", location_type: :city, is_international_city: true)
  end
  let!(:state) { Location.create!(name: "State #{SecureRandom.hex(4)}", location_type: :state) }
  let!(:district) { Location.create!(name: "District #{SecureRandom.hex(4)}", location_type: :district, parent: state) }

  let(:query) do
    <<~GQL
      query ListLocations($type: String, $parentId: Int, $isInternationalCity: Boolean) {
        locationList(type: $type, parentId: $parentId, isInternationalCity: $isInternationalCity) {
          id
          name
          locationType
        }
      }
    GQL
  end

  let(:variables) { {} }
  let(:result) { gql_execute(query, variables: variables, context: {}) }
  let(:locations) { result.dig('data', 'locationList') }
  let(:names) { locations.map { |l| l['name'] } }

  it 'lists locations, including international ones when untyped' do
    expect(names).to include(indian_city.name, international_city.name, state.name, district.name)
  end

  it 'filters by type, excluding international cities by default' do
    variables[:type] = 'city'

    expect(names).to include(indian_city.name)
    expect(names).not_to include(international_city.name, state.name, district.name)
  end

  it 'includes international cities when asked' do
    variables[:type] = 'city'
    variables[:isInternationalCity] = true

    expect(names).to include(indian_city.name, international_city.name)
    expect(names).not_to include(state.name, district.name)
  end

  it 'filters by parent' do
    variables[:parentId] = state.id

    expect(names).to contain_exactly(district.name)
  end
end
