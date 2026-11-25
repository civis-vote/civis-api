require "rails_helper"

RSpec.describe "Consultation admin", type: :request do
  let(:department) { create(:department) }
  let(:consultation) { create(:consultation, department:, status: :submitted) }

  before { cm_admin_sign_in }

  describe "show" do
    it "shows the profile fields" do
      expect(cm_admin_show(consultation)).to have_field(:title).with_value(consultation.title)
      expect(cm_admin_show(consultation)).to have_field(:status).with_value("SUBMITTED")
    end

    it "lists the response rounds tab" do
      # Consultation#create already opens its first response round.
      expect(cm_admin_show(consultation, tab: :response_rounds)).to list_records(*consultation.response_rounds)
    end

    it "lists the clauses tab" do
      clause = create(:clause, consultation:)

      expect(cm_admin_show(consultation, tab: :clauses)).to list_records(clause)
    end
  end

  describe "publish and reject" do
    it "publishes a submitted consultation" do
      expect(consultation).to offer_action(:publish)
      expect(cm_admin_run(consultation, :publish)).to succeed
      expect(consultation.reload).to be_published
    end

    it "rejects a published consultation" do
      published = create(:consultation, department:, status: :published)

      expect(published).to offer_action(:reject)
      expect(cm_admin_run(published, :reject)).to succeed
      expect(published.reload).to be_rejected
    end

    it "offers publish only while submitted or rejected" do
      published = create(:consultation, department:, status: :published)

      expect(published).not_to offer_action(:publish)
      expect(published).to offer_action(:reject)
    end
  end

  describe "bulk actions" do
    it "deletes selected consultations" do
      first = create(:consultation, department:)
      second = create(:consultation, department:)

      expect(cm_admin_run_bulk(Consultation, :delete, [first, second])).to succeed
      expect(first.reload).to be_deleted
      expect(second.reload).to be_deleted
    end

    it "duplicates a consultation" do
      result = nil
      expect { result = cm_admin_run_bulk(Consultation, :duplicate, [consultation]) }
        .to change(Consultation, :count).by(2)
      expect(result).to succeed
    end
  end

  describe "forms" do
    it "creates a consultation" do
      result = cm_admin_create(Consultation, title: "New consultation", department_id: department.id,
                                             url: "https://example.com/consultation.pdf",
                                             response_deadline: "2026-12-30")

      expect(result).to create_record(Consultation).with(title: "New consultation", department:)
    end

    it "needs a department" do
      expect(cm_admin_create(Consultation, title: "No department")).to have_validation_error(:department_id)
    end

    it "renames a consultation" do
      expect(cm_admin_update(consultation, title: "Renamed")).to succeed
      expect(consultation.reload.title).to eq("Renamed")
    end
  end

  describe "access" do
    it "lets an organisation employee open only their organisation's consultations" do
      organisation = create(:organisation)
      employee = create(:user, role: :organisation_employee, organisation:,
                               cm_role: cm_admin_role(Consultation => { index: :organisation_only, show: :organisation_only }))
      own = create(:consultation, department:, status: :published, visibility: :private_consultation, organisation:)
      other_org = create(:consultation, department:, status: :published, visibility: :private_consultation,
                                        organisation: create(:organisation))

      # The index is a kanban view, which the listing helpers cannot read; assert the show pages instead.
      expect(cm_admin_access(Consultation, :index, as: employee)).to eq(:allowed)
      expect(employee).to be_allowed_to(:show, own)
      expect(employee).not_to be_allowed_to(:show, other_org)
    end
  end
end
