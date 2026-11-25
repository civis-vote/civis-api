require 'rails_helper'

RSpec.describe Mutations::Auth::ResendVerificationEmail, type: :graphql do
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: 'resend@example.com',
                 password: 'Password@123', role: :citizen)
  end

  let(:query) do
    <<~GQL
      mutation ResendVerificationEmail($email: String!) {
        authResendVerificationEmail(email: $email)
      }
    GQL
  end

  let(:variables) { { email: user.email } }
  let(:result) { gql_execute(query, variables: variables, context: {}) }

  # Documents a gap: User#send_email_verification is not implemented anywhere,
  # so the mutation 500s for every known email.
  it 'fails because the verification sender is not implemented' do
    expect(result.dig('data', 'authResendVerificationEmail')).to be_nil
    expect(result['errors'].first['message']).to include('send_email_verification')
  end

  describe 'with an unknown email' do
    let(:variables) { { email: 'nobody@example.com' } }

    it 'rejects the request' do
      expect(result.dig('data', 'authResendVerificationEmail')).to be_nil
      expect(result['errors'].first['message']).to eq('Email not found')
    end
  end
end
