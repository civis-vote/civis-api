require "rails_helper"

RSpec.describe "Constant admin", type: :request do
  let!(:segments) do
    ["Urban governance", "Climate action"].map { |name| Constant.create!(name:, constant_type: :segment) }
  end
  let(:constant) { segments.first }
  let!(:clause_type) { Constant.create!(name: "Taxation", constant_type: :clause_type) }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists constants" do
      expect(cm_admin_index(Constant)).to list_records(*segments, clause_type)
    end

    it "finds a constant by search" do
      expect(cm_admin_index(Constant, search: constant.name)).to list_records(constant)
    end

    it "filters by constant type" do
      expect(cm_admin_index(Constant, filters: { constant_type: ["segment"] })).to list_records(*segments)
    end
  end

  it "shows a constant" do
    expect(cm_admin_show(constant)).to have_field(:name).with_value(constant.name)
  end

  it "creates a constant" do
    expect(cm_admin_create(Constant, name: "Air quality", constant_type: "segment"))
      .to create_record(Constant).with(name: "Air quality", constant_type: "segment")
  end
end
