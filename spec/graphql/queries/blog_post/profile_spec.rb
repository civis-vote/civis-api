# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Queries::BlogPost::Profile, type: :graphql do
  let(:query) do
    <<~GQL
      query GetBlogPost($slug: String!) {
        blogPostProfile(slug: $slug) {
          id
          title
          slug
          description
          content
          createdByName
          blogCategory {
            name
            hexCode
          }
          publishedAt
        }
      }
    GQL
  end

  let(:variables) { { slug: post.slug } }
  let(:result) { CivisApiSchema.execute(query, variables: variables, context: {}) }
  let(:fetched) { result.dig('data', 'blogPostProfile') }

  describe 'blogPostProfile query' do
    context 'when the post is published' do
      let(:post) { Fabricate(:blog_post, status: :published) }

      it 'returns the post' do
        expect(fetched['id'].to_i).to eq(post.id)
        expect(fetched['slug']).to eq(post.slug)
        expect(fetched['content']).to be_present
      end
    end

    context 'when the post is a draft' do
      let(:post) { Fabricate(:blog_post, status: :draft) }

      it 'returns nil' do
        expect(fetched).to be_nil
      end
    end
  end
end
