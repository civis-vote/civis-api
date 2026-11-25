require 'rails_helper'

RSpec.describe OtpRequest, type: :model do
  let(:user) { User.create!(email: Faker::Internet.unique.email, role: :citizen) }

  describe '.delivery_channel_for' do
    it 'returns email for an email identifier' do
      expect(described_class.delivery_channel_for('a@b.com')).to eq(:email)
    end

    it 'returns phone for anything else' do
      expect(described_class.delivery_channel_for('+919876543210')).to eq(:phone)
      expect(described_class.delivery_channel_for('9876543210')).to eq(:phone)
    end
  end

  describe '#deliver_otp' do
    it 'enqueues the email job for email channel' do
      expect do
        user.create_otp_request(delivery_channel: :email)
      end.to have_enqueued_job(SendOtpEmailJob)
    end

    it 'enqueues the whatsapp job for phone channel' do
      phone_user = User.create!(phone_number: '+919876501234', role: :citizen)
      expect do
        phone_user.create_otp_request(delivery_channel: :phone)
      end.to have_enqueued_job(SendOtpWhatsappJob)
    end
  end
end
