require 'rails_helper'

RSpec.describe Queries::Theme::List, type: :graphql do
  let!(:themes) { Array.new(3) { Theme.create!(name: "Theme #{SecureRandom.hex(4)}") } }

  let(:query) do
    <<~GQL
      query ListThemes($page: Int, $perPage: Int) {
        themeList(page: $page, perPage: $perPage) {
          data { id name }
          paging { totalItems }
        }
      }
    GQL
  end

  let(:result) { gql_execute(query, variables: {}, context: {}) }
  let(:listed) { result.dig('data', 'themeList') }

  it 'lists themes with a page count' do
    expect(listed['data'].size).to eq(3)
    expect(listed['paging']['totalItems']).to eq(3)
  end

  it 'paginates' do
    result = gql_execute(query, variables: { page: 1, perPage: 2 }, context: {})

    expect(result.dig('data', 'themeList', 'data').size).to eq(2)
  end
end
