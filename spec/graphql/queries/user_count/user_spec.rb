require 'rails_helper'

RSpec.describe Queries::UserCount::User, type: :graphql do
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let!(:user_count) { UserCount.create!(user_id: user.id, profanity_count: 2, short_response_count: 3) }

  let(:query) do
    <<~GQL
      query UserCount($userId: Int) {
        userCountUser(userId: $userId) {
          userId
          profanityCount
          shortResponseCount
        }
      }
    GQL
  end

  let(:variables) { { userId: user.id } }
  let(:result) { gql_execute(query, variables: variables, context: {}) }
  let(:record) { result.dig('data', 'userCountUser') }

  it 'returns the counter record for the user' do
    expect(record['userId'].to_i).to eq(user.id)
    expect(record['profanityCount']).to eq(2)
    expect(record['shortResponseCount']).to eq(3)
  end

  it 'returns nothing for a user without counters' do
    other = User.create!(first_name: 'Other', last_name: 'User', email: Faker::Internet.unique.email,
                         password: 'Password@123', role: :citizen, confirmed_at: Time.current)

    result = gql_execute(query, variables: { userId: other.id }, context: {})

    expect(result.dig('data', 'userCountUser')).to be_nil
  end
end
