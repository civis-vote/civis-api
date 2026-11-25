require 'rails_helper'

RSpec.describe Mutations::UserCount::Update, type: :graphql do
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let!(:user_count) { UserCount.create!(user_id: user.id, profanity_count: 1, short_response_count: 1) }

  let(:query) do
    <<~GQL
      mutation UpdateUserCount($userCount: UserCountInput!) {
        userCountUpdate(userCount: $userCount) {
          profanityCount
          shortResponseCount
        }
      }
    GQL
  end

  let(:variables) { { userCount: { userId: user.id, profanityCount: 5, shortResponseCount: 6 } } }
  let(:result) { gql_execute(query, variables: variables, context: {}) }

  it 'updates the counters' do
    expect(result['errors']).to be_nil
    expect(user_count.reload.profanity_count).to eq(5)
    expect(user_count.reload.short_response_count).to eq(6)
  end

  describe 'when no counter exists yet' do
    before { user_count.destroy }

    it 'errors instead of creating one' do
      expect(result.dig('data', 'userCountUpdate')).to be_nil
      expect(result['errors']).not_to be_empty
    end
  end
end
