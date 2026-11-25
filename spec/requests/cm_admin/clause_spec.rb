require "rails_helper"

RSpec.describe "Clause admin", type: :request do
  let(:department) { create(:department) }
  let(:consultation) { create(:consultation, department:) }
  let!(:clauses) do
    [
      create(:clause, consultation:, clause_title: "Definition of waste"),
      create(:clause, consultation:, clause_title: "Penalty provisions")
    ]
  end
  let(:clause) { clauses.first }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists clauses" do
      expect(cm_admin_index(Clause)).to list_records(*clauses)
    end

    it "finds a clause by search" do
      expect(cm_admin_index(Clause, search: clause.clause_title)).to list_records(clause)
    end
  end

  it "shows a clause" do
    expect(cm_admin_show(clause)).to have_field(:clause_title).with_value(clause.clause_title)
  end

  # The form has no consultation field — clauses are created from the consultation page,
  # so the standalone form cannot satisfy the consultation presence validation.
  it "cannot create a clause without a consultation through the form" do
    expect(cm_admin_create(Clause, clause_id: "3.2", clause_title: "Enforcement powers"))
      .to have_validation_error(:consultation)
  end

  it "edits a clause" do
    expect(cm_admin_update(clause, clause_title: "Definitions")).to succeed
    expect(clause.reload.clause_title).to eq("Definitions")
  end
end
