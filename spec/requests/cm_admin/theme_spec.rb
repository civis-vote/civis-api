require "rails_helper"

RSpec.describe "Theme admin", type: :request do
  let!(:themes) { %w[Healthcast Climate].map { |name| Theme.create!(name:) } }
  let(:theme) { themes.first }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists themes" do
      expect(cm_admin_index(Theme)).to list_records(*themes)
    end
  end

  it "shows a theme" do
    expect(cm_admin_show(theme)).to have_field(:name).with_value(theme.name)
  end

  it "creates a theme" do
    expect(cm_admin_create(Theme, name: "Governance")).to create_record(Theme).with(name: "Governance")
  end

  it "edits a theme" do
    expect(cm_admin_update(theme, name: "Public Health")).to succeed
    expect(theme.reload.name).to eq("Public Health")
  end
end
