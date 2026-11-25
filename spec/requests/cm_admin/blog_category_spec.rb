require "rails_helper"

RSpec.describe "Blog category admin", type: :request do
  let!(:categories) { %w[Health Education Environment].map { |name| create(:blog_category, name:) } }
  let(:blog_category) { categories.first }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists blog categories" do
      expect(cm_admin_index(BlogCategory)).to list_records(*categories)
    end
  end

  it "shows a blog category" do
    expect(cm_admin_show(blog_category)).to have_field(:name).with_value(blog_category.name)
  end

  it "creates a blog category" do
    expect(cm_admin_create(BlogCategory, name: "Governance"))
      .to create_record(BlogCategory).with(name: "Governance")
  end

  it "needs a name" do
    expect(cm_admin_create(BlogCategory, name: "")).to have_validation_error(:name)
  end

  it "edits a blog category" do
    expect(cm_admin_update(blog_category, name: "Public Health")).to succeed
    expect(blog_category.reload.name).to eq("Public Health")
  end
end
