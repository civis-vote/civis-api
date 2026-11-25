require "rails_helper"

RSpec.describe "Showcase slide admin", type: :request do
  let!(:slides) do
    [
      Fabricate(:showcase_slide, title: "Draft slide", status: :draft, published_at: nil),
      Fabricate(:showcase_slide, title: "Live slide", status: :published)
    ]
  end
  let(:draft) { slides.first }
  let(:published) { slides.last }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists showcase slides" do
      expect(cm_admin_index(ShowcaseSlide)).to list_records(*slides)
    end

    it "finds a slide by search" do
      expect(cm_admin_index(ShowcaseSlide, search: draft.title)).to list_records(draft)
    end
  end

  it "shows a showcase slide" do
    expect(cm_admin_show(published)).to have_field(:title).with_value(published.title)
  end

  it "publishes a draft" do
    expect(draft).to offer_action(:publish)
    expect(cm_admin_run(draft, :publish)).to succeed
    expect(draft.reload).to be_published
  end

  it "archives a published slide" do
    expect(published).to offer_action(:archive)
    expect(cm_admin_run(published, :archive)).to succeed
    expect(published.reload).to be_archived
  end

  it "needs a title" do
    expect(cm_admin_create(ShowcaseSlide, title: "")).to have_validation_error(:title)
  end

  it "edits a showcase slide" do
    expect(cm_admin_update(published, cta_label: "Read the report")).to succeed
    expect(published.reload.cta_label).to eq("Read the report")
  end
end
