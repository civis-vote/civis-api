require 'rails_helper'

RSpec.describe Mutations::Auth::Login, type: :graphql do
  let(:query) do
    <<~GQL
      mutation AuthLogin($auth: Login!) {
        authLogin(auth: $auth)
      }
    GQL
  end

  let(:result) { CivisApiSchema.execute(query, variables: variables, context: {}) }

  describe 'email login' do
    let(:variables) { { auth: { email: 'new.user@example.com' } } }

    it 'creates the user and an email OTP request' do
      expect { result }.to change { User.where(email: 'new.user@example.com').count }.by(1)
      expect(result['errors']).to be_nil
      expect(result.dig('data', 'authLogin')).to be true

      otp_request = User.find_by(email: 'new.user@example.com').otp_requests.last
      expect(otp_request.delivery_channel).to eq('email')
    end

    it 'reuses an existing user' do
      user = User.create!(email: 'new.user@example.com', role: :citizen)
      expect { result }.not_to(change { User.count })
      expect(user.otp_requests.last.delivery_channel).to eq('email')
    end
  end

  describe 'phone login' do
    let(:variables) { { auth: { phoneNumber: '9876543210' } } }

    it 'creates the user with a normalized phone number and a phone OTP request' do
      expect { result }.to change { User.where(phone_number: '+919876543210').count }.by(1)
      expect(result['errors']).to be_nil

      user = User.find_by(phone_number: '+919876543210')
      expect(user.email).to be_nil
      expect(user.otp_requests.last.delivery_channel).to eq('phone')
    end

    it 'reuses an existing user' do
      user = User.create!(phone_number: '+919876543210', role: :citizen)
      expect { result }.not_to(change { User.count })
      expect(user.otp_requests.last.delivery_channel).to eq('phone')
    end
  end

  describe 'with neither email nor phone' do
    let(:variables) { { auth: {} } }

    it 'returns a bad request error' do
      expect(result.dig('data', 'authLogin')).to be_nil
      expect(result['errors']).not_to be_empty
    end
  end
end
