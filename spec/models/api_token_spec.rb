require 'rails_helper'

RSpec.describe ApiToken, type: :model do
  let(:user) { create(:user) }

  it 'generates a token on create' do
    api_token = ApiToken.create!(user: user, name: 'CI token', token_type: :pat)

    expect(api_token.token).to match(/\A\h{64}\z/)
  end

  describe 'validations' do
    it 'needs a name, token type and user' do
      expect(ApiToken.new(user: user)).not_to be_valid
    end

    it 'caps the name at 100 characters' do
      api_token = ApiToken.new(user: user, name: 'x' * 101, token_type: :access)

      expect(api_token).not_to be_valid
    end
  end

  describe '#live? and #expired?' do
    it 'is live without an expiry' do
      api_token = ApiToken.create!(user: user, name: 'No expiry', token_type: :access, expires_at: nil)

      expect(api_token).to be_live
      expect(api_token.status).to eq('live')
    end

    it 'is expired once the expiry passes' do
      api_token = ApiToken.create!(user: user, name: 'Old token', token_type: :access)
      api_token.update_columns(expires_at: 1.day.ago)

      expect(api_token).to be_expired
      expect(api_token.status).to eq('expired')
    end
  end

  describe '#token_type_display' do
    it 'labels a personal access token as PAT' do
      api_token = ApiToken.create!(user: user, name: 'PAT', token_type: :pat)

      expect(api_token.token_type_display).to eq('PAT')
    end

    it 'titleizes other token types' do
      api_token = ApiToken.create!(user: user, name: 'Refresh', token_type: :refresh)

      expect(api_token.token_type_display).to eq('Refresh')
    end
  end
end
