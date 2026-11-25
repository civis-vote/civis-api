require "rails_helper"

RSpec.describe "Organisation admin", type: :request do
  before { cm_admin_sign_in }

  # set_created_by stamps created_by from the signed-in admin.
  let!(:organisations) do
    ["Acme Foundation", "Civic Trust"].map { |name| Organisation.create!(name:) }
  end
  let(:organisation) { organisations.first }

  describe "index" do
    it "lists organisations" do
      expect(cm_admin_index(Organisation)).to list_records(*organisations)
    end

    it "finds an organisation by search" do
      expect(cm_admin_index(Organisation, search: organisation.name)).to list_records(organisation)
    end
  end

  it "shows an organisation" do
    expect(cm_admin_show(organisation)).to have_field(:name).with_value(organisation.name)
  end

  it "creates an organisation" do
    expect(cm_admin_create(Organisation, name: "New Trust"))
      .to create_record(Organisation).with(name: "New Trust")
  end

  it "edits an organisation" do
    expect(cm_admin_update(organisation, official_url: "https://example.org")).to succeed
    expect(organisation.reload.official_url).to eq("https://example.org")
  end
end
