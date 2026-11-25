require "rails_helper"

RSpec.describe "Location admin", type: :request do
  let!(:state) { Location.create!(name: "Maharashtra", location_type: :state) }
  let!(:cities) do
    %w[Pune Mumbai].map { |name| Location.create!(name:, location_type: :city, parent: state) }
  end
  let!(:international_city) do
    Location.create!(name: "Singapore", location_type: :city, is_international_city: true)
  end
  let(:location) { cities.first }

  before { cm_admin_sign_in }

  describe "index" do
    it "finds a location by search" do
      expect(cm_admin_index(Location, search: location.name)).to list_records(location)
    end

    it "filters by location type" do
      expect(cm_admin_index(Location, filters: { location_type: ["state"] })).to list_records(state)
    end
  end

  it "shows a location" do
    expect(cm_admin_show(location)).to have_field(:name).with_value(location.name)
  end

  it "creates a location" do
    expect(cm_admin_create(Location, name: "Nagpur", location_type: "city", parent_id: state.id))
      .to create_record(Location).with(name: "Nagpur", location_type: "city", parent: state)
  end

  it "needs a name" do
    expect(cm_admin_create(Location, location_type: "city")).to have_validation_error(:name)
  end

  it "edits a location" do
    expect(cm_admin_update(location, is_international_city: true)).to succeed
    expect(location.reload.is_international_city).to be(true)
  end
end
