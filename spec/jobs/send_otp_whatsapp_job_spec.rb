require 'rails_helper'

RSpec.describe SendOtpWhatsappJob, type: :job do
  let(:user) { User.create!(phone_number: '+919876501234', role: :citizen) }

  it 'delivers the OTP through the Gupshup provider' do
    otp_request = user.otp_requests.create!(otp: '123456', status: :created, delivery_channel: :phone)
    provider = instance_double(GupshupWhatsappDelivery)
    allow(GupshupWhatsappDelivery).to receive(:new).and_return(provider)
    expect(provider).to receive(:deliver).with(user: user, otp: '123456', template: :otp)

    described_class.new.perform(otp_request.id)
  end
end
