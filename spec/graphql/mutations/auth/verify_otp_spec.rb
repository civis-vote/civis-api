require 'rails_helper'

RSpec.describe Mutations::Auth::VerifyOtp, type: :graphql do
  let(:query) do
    <<~GQL
      mutation VerifyOtp($auth: VerifyOtp!) {
        verifyOtp(auth: $auth) {
          accessToken
        }
      }
    GQL
  end

  let(:result) { CivisApiSchema.execute(query, variables: variables, context: {}) }

  describe 'email OTP' do
    let(:user) { User.create!(email: 'otp.user@example.com', role: :citizen) }
    let(:variables) { { auth: { email: user.email, otp: otp } } }
    let(:otp) { user.otp_requests.active.last.otp.to_s }

    before { user.create_otp_request(delivery_channel: :email) }

    it 'returns an api key and confirms the user' do
      expect(result['errors']).to be_nil
      expect(result.dig('data', 'verifyOtp', 'accessToken')).to be_present
      expect(user.reload.confirmed_at).to be_present
    end

    context 'with a wrong OTP' do
      let(:otp) { '000000' }

      it 'returns a failed login error' do
        expect(result.dig('data', 'verifyOtp')).to be_nil
        expect(result['errors']).not_to be_empty
      end
    end
  end

  describe 'phone OTP' do
    let(:user) { User.create!(phone_number: '+919812345678', role: :citizen) }
    let(:variables) { { auth: { phoneNumber: '9812345678', otp: otp } } }
    let(:otp) { user.otp_requests.active.last.otp.to_s }

    before { user.create_otp_request(delivery_channel: :phone) }

    it 'finds the user by normalized phone and returns an api key' do
      expect(result['errors']).to be_nil
      expect(result.dig('data', 'verifyOtp', 'accessToken')).to be_present
      expect(user.reload.phone_verified_at).to be_present
    end
  end
end
