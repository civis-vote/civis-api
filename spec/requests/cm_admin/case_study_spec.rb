require "rails_helper"

RSpec.describe "Case study admin", type: :request do
  let!(:case_studies) do
    ["Waste management in Pune", "Water conservation in Rajasthan"].map do |name|
      create(:case_study, name:)
    end
  end
  let(:case_study) { case_studies.first }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists case studies" do
      expect(cm_admin_index(CaseStudy)).to list_records(*case_studies)
    end

    it "finds a case study by search" do
      expect(cm_admin_index(CaseStudy, search: "waste")).to list_records(case_study)
    end
  end

  it "shows a case study" do
    expect(cm_admin_show(case_study)).to have_field(:name).with_value(case_study.name)
  end

  it "creates a case study" do
    expect(cm_admin_create(CaseStudy, name: "Solar rooftops in Delhi", ministry_name: "MNRE",
                                      case_study_type: "government"))
      .to create_record(CaseStudy).with(name: "Solar rooftops in Delhi", ministry_name: "MNRE")
  end

  it "needs a name" do
    expect(cm_admin_create(CaseStudy, ministry_name: "MNRE")).to have_validation_error(:name)
  end

  it "edits a case study" do
    expect(cm_admin_update(case_study, no_of_citizens: 42)).to succeed
    expect(case_study.reload.no_of_citizens).to eq(42)
  end
end
