require "rails_helper"

RSpec.describe "Respondent admin", type: :request do
  let(:department) { create(:department) }
  let(:consultation) { create(:consultation, department:) }
  let(:response_round) { consultation.response_rounds.first }
  let!(:respondents) do
    [%w[Asha Rao], %w[Vikram Sen]].map do |first_name, last_name|
      user = create(:user, first_name:, last_name:)
      create(:respondent, user:, response_round:)
    end
  end
  let(:respondent) { respondents.first }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists respondents" do
      expect(cm_admin_index(Respondent)).to list_records(*respondents)
    end

    it "finds a respondent by user id" do
      expect(cm_admin_index(Respondent, search: respondent.user_id.to_s)).to list_records(respondent)
    end
  end

  it "destroys a respondent" do
    cm_admin_request(:delete, cm_admin_path(Respondent, :destroy, respondent))

    expect(Respondent.exists?(respondent.id)).to be(false)
  end
end
