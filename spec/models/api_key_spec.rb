require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  let(:user) { create(:user) }

  describe '.verify' do
    it 'returns the key for a live access token' do
      api_key = user.api_keys.create

      expect(ApiKey.verify(api_key.access_token)).to eq(api_key)
    end

    it 'returns nothing for an unknown token' do
      expect(ApiKey.verify('not-a-token')).to be_blank
    end

    it 'returns nothing for an expired token' do
      api_key = user.api_keys.create
      api_key.update_columns(expires_at: Date.yesterday)

      expect(ApiKey.verify(api_key.access_token)).to be_blank
    end
  end

  it 'generates an access token and a 30-day expiry on save' do
    api_key = user.api_keys.create

    expect(api_key.access_token).to match(/\A\h{32}\z/)
    expect(api_key.expires_at).to eq(Date.today + 30)
  end
end
