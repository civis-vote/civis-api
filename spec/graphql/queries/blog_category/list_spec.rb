# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Queries::BlogCategory::List, type: :graphql do
  let(:query) do
    <<~GQL
      query GetBlogCategories {
        blogCategoryList {
          data {
            id
            name
            iconName
            hexCode
          }
          paging {
            totalItems
          }
        }
      }
    GQL
  end

  let(:result) { CivisApiSchema.execute(query, context: {}) }
  let(:categories) { result.dig('data', 'blogCategoryList', 'data') }

  it 'returns all categories ordered by name' do
    Fabricate(:blog_category, name: 'Zebra')
    alpha = Fabricate(:blog_category, name: 'Alpha')

    expect(categories.map { |c| c['id'].to_i }).to eq([alpha.id, BlogCategory.find_by(name: 'Zebra').id])
  end
end
