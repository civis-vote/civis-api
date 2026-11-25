require 'rails_helper'

RSpec.describe Mutations::Auth::ConfirmEmail, type: :graphql do
  let(:user) do
    User.create!(email: 'confirm.me@example.com', role: :citizen).tap do |user|
      user.update_column(:confirmation_token, 'real-token')
    end
  end

  let(:query) do
    <<~GQL
      mutation ConfirmEmail($confirmationToken: String!) {
        authConfirmEmail(confirmationToken: $confirmationToken) { accessToken expiresAt }
      }
    GQL
  end

  let(:variables) { { confirmationToken: user.confirmation_token } }
  let(:result) { gql_execute(query, variables: variables, context: {}) }

  # Documents a gap: Devise :confirmable is not enabled, so User#confirm does not
  # exist and the mutation 500s even with a valid token.
  it 'finds the user by token but fails to confirm them' do
    expect(result.dig('data', 'authConfirmEmail')).to be_nil
    expect(result['errors'].first['message']).to include('confirm')
    expect(user.reload.confirmed_at).to be_nil
  end

  describe 'with an unknown token' do
    let(:variables) { { confirmationToken: 'not-a-real-token' } }

    it 'rejects the confirmation' do
      expect(result.dig('data', 'authConfirmEmail')).to be_nil
      expect(result['errors'].first['message']).to eq('User is not authorized to perform this action')
    end
  end
end
