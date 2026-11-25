require 'rails_helper'

RSpec.describe Mutations::UserCount::Create, type: :graphql do
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      mutation CreateUserCount($userCount: UserCountInput!) {
        userCountCreate(userCount: $userCount) {
          userId
          profanityCount
          shortResponseCount
        }
      }
    GQL
  end

  let(:variables) { { userCount: { userId: user.id, profanityCount: 2, shortResponseCount: 3 } } }
  let(:result) { gql_execute(query, variables: variables, context: {}) }
  let(:created) { result.dig('data', 'userCountCreate') }

  it 'creates the counter record' do
    expect(result['errors']).to be_nil
    record = UserCount.find_by(user_id: user.id)

    expect(record.user_id).to eq(user.id)
    expect(record.profanity_count).to eq(2)
    expect(record.short_response_count).to eq(3)
  end

  describe 'when the counter already exists' do
    before do
      UserCount.create!(user_id: user.id, profanity_count: 9, short_response_count: 9)
    end

    it 'overwrites the counters instead of duplicating' do
      expect { result }.not_to(change { UserCount.count })
      record = UserCount.find_by(user_id: user.id)

      expect(record.profanity_count).to eq(2)
      expect(record.short_response_count).to eq(3)
    end
  end
end
