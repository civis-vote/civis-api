require "rails_helper"

RSpec.describe "Wordindex admin", type: :request do
  let!(:words) { %w[abrogate belletristic cogent].map { |word| create(:wordindex, word:) } }
  let(:wordindex) { words.first }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists glossary words" do
      expect(cm_admin_index(Wordindex)).to list_records(*words)
    end

    it "finds a word by search" do
      expect(cm_admin_index(Wordindex, search: wordindex.word)).to list_records(wordindex)
    end
  end

  it "shows a glossary word" do
    expect(cm_admin_show(wordindex)).to have_field(:word).with_value(wordindex.word)
  end

  it "creates a glossary word" do
    expect(cm_admin_create(Wordindex, word: "ephemeral", description: "Lasts a very short time"))
      .to create_record(Wordindex).with(word: "ephemeral")
  end

  it "needs a word" do
    expect(cm_admin_create(Wordindex, description: "No word given")).to have_validation_error(:word)
  end

  it "edits a glossary word" do
    expect(cm_admin_update(wordindex, description: "Updated description")).to succeed
    expect(wordindex.reload.description).to eq("Updated description")
  end
end
