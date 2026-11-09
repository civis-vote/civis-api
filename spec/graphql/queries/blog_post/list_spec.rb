# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Queries::BlogPost::List, type: :graphql do
  let(:query) do
    <<~GQL
      query GetBlogPosts($blogCategoryFilter: Int, $yearFilter: Int, $searchFilter: String, $sort: BlogPostSorts, $sortDirection: SortDirections, $page: Int, $perPage: Int) {
        blogPostList(blogCategoryFilter: $blogCategoryFilter, yearFilter: $yearFilter, searchFilter: $searchFilter, sort: $sort, sortDirection: $sortDirection, page: $page, perPage: $perPage) {
          data {
            id
            title
            slug
            description
            blogCategory {
              id
              name
              iconName
              hexCode
            }
            publishedAt
          }
          paging {
            currentPage
            totalItems
            totalPages
          }
          years
        }
      }
    GQL
  end

  let(:variables) { {} }
  let(:result) { CivisApiSchema.execute(query, variables: variables, context: {}) }
  let(:posts) { result.dig('data', 'blogPostList', 'data') }
  let(:paging) { result.dig('data', 'blogPostList', 'paging') }

  describe 'blogPostList query' do
    it 'returns only published posts' do
      published = Fabricate(:blog_post, status: :published)
      Fabricate(:blog_post, status: :draft)
      Fabricate(:blog_post, status: :archived)

      expect(posts.map { |p| p['id'].to_i }).to eq([published.id])
      expect(result['errors']).to be_nil
    end

    it 'filters by blog category' do
      category = Fabricate(:blog_category)
      post = Fabricate(:blog_post, blog_category: category)
      Fabricate(:blog_post)

      variables.merge!(blogCategoryFilter: category.id)
      expect(posts.map { |p| p['id'].to_i }).to eq([post.id])
      expect(posts.first.dig('blogCategory', 'id').to_i).to eq(category.id)
    end

    it 'filters by year' do
      post = Fabricate(:blog_post, published_at: Time.zone.local(2024, 6, 1))
      Fabricate(:blog_post, published_at: Time.zone.local(2025, 6, 1))

      variables.merge!(yearFilter: 2024)
      expect(posts.map { |p| p['id'].to_i }).to eq([post.id])
    end

    it 'returns distinct published years' do
      Fabricate(:blog_post, published_at: Time.zone.local(2024, 6, 1))
      Fabricate(:blog_post, published_at: Time.zone.local(2025, 6, 1))
      Fabricate(:blog_post, status: :draft, published_at: Time.zone.local(2020, 1, 1))

      expect(result.dig('data', 'blogPostList', 'years')).to eq([2025, 2024])
    end

    it 'searches by title' do
      post = Fabricate(:blog_post, title: 'Consultation Reform Digest')
      Fabricate(:blog_post, title: 'Completely different words')

      variables.merge!(searchFilter: 'reform digest')
      expect(posts.map { |p| p['id'].to_i }).to eq([post.id])
    end

    it 'orders by published_at desc by default' do
      older = Fabricate(:blog_post, published_at: 2.days.ago)
      newer = Fabricate(:blog_post, published_at: 1.day.ago)

      expect(posts.map { |p| p['id'].to_i }).to eq([newer.id, older.id])
    end

    it 'paginates results' do
      Fabricate.times(3, :blog_post)
      variables.merge!(perPage: 2, page: 1)

      expect(posts.size).to eq(2)
      expect(paging['totalItems']).to eq(3)
      expect(paging['totalPages']).to eq(2)
    end
  end
end
