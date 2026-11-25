require 'rails_helper'

RSpec.describe Mutations::Auth::SignUp, type: :graphql do
  let(:query) do
    <<~GQL
      mutation SignUp($auth: SignUp!) {
        authSignUp(auth: $auth) { accessToken expiresAt }
      }
    GQL
  end

  let(:variables) do
    { auth: { email: 'new.citizen@example.com', firstName: 'New', lastName: 'Citizen',
              password: 'Password@123' } }
  end

  let(:result) { gql_execute(query, variables: variables, context: {}) }

  it 'creates the citizen account' do
    expect { result }.to change { User.where(email: 'new.citizen@example.com').count }.by(1)
  end

  # Documents a gap: the mutation reads live_api_key without creating one, so a fresh
  # sign-up returns null and the client must log in via OTP to get a token.
  it 'returns no access token for a fresh account' do
    result
    user = User.find_by(email: 'new.citizen@example.com')

    expect(user.api_keys).to be_empty
    expect(result.dig('data', 'authSignUp', 'accessToken')).to be_nil
    expect(result['errors'].first['message']).to eq('Cannot return null for non-nullable field Mutation.authSignUp')
  end

  describe 'with a weak password' do
    let(:variables) { { auth: { email: 'new.citizen@example.com', firstName: 'New', password: 'weak' } } }

    it 'rejects the sign-up' do
      expect { result }.not_to(change { User.count })
      expect(result['errors']).not_to be_empty
    end
  end

  describe 'with a duplicate email' do
    before do
      User.create!(email: 'new.citizen@example.com', role: :citizen)
    end

    it 'rejects the sign-up' do
      expect { result }.not_to(change { User.count })
      expect(result['errors']).not_to be_empty
    end
  end
end
