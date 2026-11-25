require "rails_helper"

RSpec.describe "Consultation response admin", type: :request do
  let(:department) { create(:department) }
  let(:consultation) { create(:consultation, :published, department:) }
  let(:user) { create(:user) }

  let!(:under_review) do
    create(:consultation_response, consultation:, user:, response_status: :under_review,
                                   response_text: "Needs a look")
  end
  let!(:acceptable) do
    create(:consultation_response, consultation:, response_status: :acceptable,
                                   response_text: "A good response")
  end

  before { cm_admin_sign_in }

  describe "index" do
    it "lists consultation responses" do
      expect(cm_admin_index(ConsultationResponse)).to list_records(under_review, acceptable)
    end

    it "filters by department" do
      expect(cm_admin_index(ConsultationResponse, filters: { department: [department.id] }))
        .to list_records(under_review, acceptable)
    end
  end

  it "shows a consultation response" do
    expect(cm_admin_show(acceptable)).to have_field(:response_status).with_value("Acceptable")
  end

  describe "approve and reject" do
    it "approves an under-review response" do
      expect(under_review).to offer_action(:Approve)
      expect(cm_admin_run(under_review, :Approve)).to succeed
      expect(under_review.reload).to be_acceptable
    end

    it "rejects an acceptable response" do
      expect(acceptable).to offer_action(:Reject)
      expect(cm_admin_run(acceptable, :Reject)).to succeed
      expect(acceptable.reload).to be_unacceptable
    end

    it "offers Approve only while under review or unacceptable" do
      expect(acceptable).not_to offer_action(:Approve)
      expect(acceptable).to offer_action(:Reject)
    end
  end
end
