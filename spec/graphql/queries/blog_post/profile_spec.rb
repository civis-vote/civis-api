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
            iconName
            hexCode
          }
          consultation {
            id
            title
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

      context 'and the post is linked to a consultation' do
        let(:department) do
          Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                             department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
        end
        let(:consultation) do
          Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                               response_deadline: 10.days.from_now, question_flow: :question_list,
                               published_at: 5.days.ago)
        end
        let(:post) { Fabricate(:blog_post, status: :published, consultation: consultation) }

        it 'returns the associated consultation' do
          expect(fetched['consultation']['id'].to_i).to eq(consultation.id)
          expect(fetched['consultation']['title']).to eq(consultation.title)
        end
      end

      context 'and the post is not linked to a consultation' do
        it 'returns nil for consultation' do
          expect(fetched['consultation']).to be_nil
        end
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
