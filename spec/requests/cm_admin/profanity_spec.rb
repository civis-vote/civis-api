require "rails_helper"

RSpec.describe "Profanity admin", type: :request do
  let!(:profanities) { %w[darn fluff].map { |word| create(:profanity, profane_word: word) } }
  let(:profanity) { profanities.first }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists profane words" do
      expect(cm_admin_index(Profanity)).to list_records(*profanities)
    end

    it "finds a word by search" do
      expect(cm_admin_index(Profanity, search: profanity.profane_word)).to list_records(profanity)
    end
  end

  it "shows a profane word" do
    expect(cm_admin_show(profanity)).to have_field(:profane_word).with_value(profanity.profane_word)
  end

  it "creates a profane word" do
    expect(cm_admin_create(Profanity, profane_word: "gosh"))
      .to create_record(Profanity).with(profane_word: "gosh")
  end

  it "needs a word" do
    expect(cm_admin_create(Profanity, profane_word: "")).to have_validation_error(:profane_word)
  end

  it "edits a profane word" do
    expect(cm_admin_update(profanity, profane_word: "heck")).to succeed
    expect(profanity.reload.profane_word).to eq("heck")
  end
end
