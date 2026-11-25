require "rails_helper"

RSpec.describe "Question admin", type: :request do
  let(:department) { create(:department) }
  let(:consultation) { create(:consultation, department:) }
  let(:response_round) { consultation.response_rounds.first }
  let!(:questions) do
    [
      response_round.questions.create!(question_text: "Do you support this?", question_type: :multiple_choice,
                                       is_optional: false),
      response_round.questions.create!(question_text: "Any comments?", question_type: :long_text,
                                       is_optional: true)
    ]
  end
  let(:question) { questions.first }

  before { cm_admin_sign_in }

  it "shows a question" do
    expect(cm_admin_show(question)).to have_field(:question_text).with_value(question.question_text)
  end

  it "lists the questions of a response round through the collection route" do
    cm_admin_request(:get, cm_admin_path(Question, :response_round_questions),
                     params: { response_round_id: response_round.id, format: :json })

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(question.question_text)
  end

  it "edits a question" do
    expect(cm_admin_update(question, question_text: "Do you back this?")).to succeed
    expect(question.reload.question_text).to eq("Do you back this?")
  end
end
