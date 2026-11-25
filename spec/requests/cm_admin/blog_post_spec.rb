require "rails_helper"

RSpec.describe "Blog post admin", type: :request do
  let!(:posts) do
    [
      Fabricate(:blog_post, title: "Draft post", status: :draft, published_at: nil),
      Fabricate(:blog_post, title: "Live post", status: :published)
    ]
  end
  let(:draft) { posts.first }
  let(:published) { posts.last }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists blog posts" do
      expect(cm_admin_index(BlogPost)).to list_records(*posts)
    end

    it "finds a post by search" do
      expect(cm_admin_index(BlogPost, search: draft.title)).to list_records(draft)
    end
  end

  it "shows a blog post" do
    expect(cm_admin_show(published)).to have_field(:title).with_value(published.title)
  end

  it "publishes a draft" do
    expect(draft).to offer_action(:publish)
    expect(cm_admin_run(draft, :publish)).to succeed
    expect(draft.reload).to be_published
  end

  it "archives a published post" do
    expect(published).to offer_action(:archive)
    expect(cm_admin_run(published, :archive)).to succeed
    expect(published.reload).to be_archived
  end

  it "needs a title" do
    expect(cm_admin_create(BlogPost, title: "")).to have_validation_error(:title)
  end

  it "edits a blog post" do
    expect(cm_admin_update(published, title: "Renamed post")).to succeed
    expect(published.reload.title).to eq("Renamed post")
  end
end
