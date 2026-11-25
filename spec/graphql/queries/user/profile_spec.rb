require 'rails_helper'

RSpec.describe Queries::User::Profile, type: :graphql do
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      query GetUser($id: Int!) {
        userProfile(id: $id) {
          id
          firstName
          points
        }
      }
    GQL
  end

  let(:result) { gql_execute(query, variables: { id: user.id }, context: {}) }
  let(:profile) { result.dig('data', 'userProfile') }

  it 'returns the user' do
    expect(profile['id'].to_i).to eq(user.id)
    expect(profile['firstName']).to eq('Test')
  end

  it 'errors for an unknown user' do
    result = gql_execute(query, variables: { id: -1 }, context: {})

    expect(result.dig('data', 'userProfile')).to be_nil
    expect(result['errors']).not_to be_empty
  end
end
