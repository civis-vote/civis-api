require "rails_helper"

RSpec.describe "Response round admin", type: :request do
  let(:department) { create(:department) }
  let(:consultation) { create(:consultation, department:) }
  let(:response_round) { consultation.response_rounds.first }
  let!(:question) do
    response_round.questions.create!(question_text: "Do you support this?", question_type: :multiple_choice,
                                     is_optional: false)
  end

  before { cm_admin_sign_in }

  describe "index" do
    it "lists response rounds" do
      expect(cm_admin_index(ResponseRound)).to list_records(response_round)
    end

    it "finds a response round by id" do
      expect(cm_admin_index(ResponseRound, search: response_round.id.to_s)).to list_records(response_round)
    end
  end

  it "shows a response round with its questions tab" do
    expect(cm_admin_show(response_round)).to have_field(:id).with_value(response_round.id)
    expect(cm_admin_show(response_round, tab: :questions)).to list_records(question)
  end
end
