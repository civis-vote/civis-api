# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlogPost, type: :model do
  it 'is valid from the fabricator' do
    record = Fabricate(:blog_post)
    expect(record).to be_valid
    expect(record.persisted?).to be true
  end

  it 'requires a title' do
    record = Fabricate.build(:blog_post, title: nil)
    expect(record).not_to be_valid
  end

  it 'requires a unique title, case-insensitively' do
    Fabricate(:blog_post, title: 'My Post')
    record = Fabricate.build(:blog_post, title: 'my post')
    expect(record).not_to be_valid
  end

  it 'parameterizes the title into a slug' do
    post = Fabricate(:blog_post, title: 'Hello World Post')
    expect(post.reload.slug).to eq('hello-world-post')
  end

  it 'updates the slug when the title changes' do
    post = Fabricate(:blog_post, title: 'Old Title')
    post.update!(title: 'New Title')
    expect(post.reload.slug).to eq('new-title')
  end

  it 'appends a suffix when the generated slug collides' do
    Fabricate(:blog_post, title: 'My Post')
    post = Fabricate(:blog_post, title: 'My Post!')
    expect(post.slug).to eq('my-post-2')
  end

  it 'defaults to draft status' do
    expect(BlogPost.new.status).to eq('draft')
  end

  describe '#publish and #archive' do
    it 'sets status and timestamps' do
      post = Fabricate(:blog_post, status: :draft, published_at: nil)
      post.publish
      expect(post.reload).to be_published
      expect(post.published_at).to be_present

      post.archive
      expect(post.reload).to be_archived
      expect(post.archived_at).to be_present
    end
  end

  describe 'scopes' do
    it 'filters by blog category' do
      category = Fabricate(:blog_category)
      post = Fabricate(:blog_post, blog_category: category)
      Fabricate(:blog_post)
      expect(BlogPost.blog_category_filter(category.id)).to eq([post])
    end

    it 'filters by published year' do
      post = Fabricate(:blog_post, published_at: Time.zone.local(2025, 5, 10))
      Fabricate(:blog_post, published_at: Time.zone.local(2024, 1, 1))
      expect(BlogPost.year_filter(2025)).to eq([post])
    end

    it 'searches title and description' do
      post = Fabricate(:blog_post, title: 'Unique Needle Title')
      Fabricate(:blog_post, title: 'Something else entirely')
      expect(BlogPost.search('unique needle')).to eq([post])
    end

    it 'uses a deterministic tiebreaker when sorting' do
      published_at = Time.zone.local(2025, 5, 10)
      first = Fabricate(:blog_post, published_at:)
      second = Fabricate(:blog_post, published_at:)

      expect(BlogPost.sort_records('published_at', 'desc')).to eq([first, second])
    end
  end
end
