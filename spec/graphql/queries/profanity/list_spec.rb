require 'rails_helper'

RSpec.describe Queries::Profanity::List, type: :graphql do
  let(:admin) do
    User.create!(first_name: 'Admin', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :admin, confirmed_at: Time.current)
  end

  before { Current.user = admin }
  after { Current.reset }

  let!(:profanities) do
    Array.new(3) { Profanity.create!(profane_word: "profane#{SecureRandom.hex(4)}") }
  end

  let(:query) do
    <<~GQL
      query ListProfanities($page: Int, $perPage: Int) {
        profanityList(page: $page, perPage: $perPage) {
          data { id profaneWord }
          paging { totalItems }
        }
      }
    GQL
  end

  let(:result) { gql_execute(query, variables: {}, context: {}) }
  let(:listed) { result.dig('data', 'profanityList') }

  it 'lists profane words' do
    words = listed['data'].map { |p| p['profaneWord'] }

    expect(words).to match_array(profanities.map(&:profane_word))
  end
end
