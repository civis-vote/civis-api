require 'rails_helper'

RSpec.describe Queries::User::CurrentUser, type: :graphql do
  let(:theme) { Theme.create!(name: "Theme #{SecureRandom.hex(4)}") }
  let(:area_of_impact) { Constant.create!(name: "AoI #{SecureRandom.hex(4)}", constant_type: :area_of_impact) }
  let(:segment) { Constant.create!(name: "Segment #{SecureRandom.hex(4)}", constant_type: :segment) }
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      query GetCurrentUser {
        userCurrent {
          id
          hasPreferences
          preferredThemes {
            id
            name
          }
          areaOfImpacts {
            id
            name
            constantType
          }
        }
      }
    GQL
  end

  let(:context) { { current_user: user } }
  let(:result) { CivisApiSchema.execute(query, context: context) }
  let(:response_data) { result.dig('data', 'userCurrent') }

  describe 'user preferences' do
    it 'returns the selected themes and areas of impact' do
      user.preferred_theme_ids = [theme.id]
      user.user_preferences.create!(preferable: area_of_impact)

      expect(result['errors']).to be_nil
      expect(response_data['preferredThemes'].map { |t| t['id'] }).to eq([theme.id])
      expect(response_data['areaOfImpacts'].map { |a| a['id'] }).to eq([area_of_impact.id])
      expect(response_data['hasPreferences']).to be true
    end

    it 'does not return non-area-of-impact constants' do
      user.constant_maps.create!(constant: segment)
      user.user_preferences.create!(preferable: Constant.create!(name: "Other #{SecureRandom.hex(4)}", constant_type: :segment))

      expect(response_data['areaOfImpacts']).to be_empty
    end

    it 'returns empty lists when no preferences are set' do
      expect(response_data['preferredThemes']).to be_empty
      expect(response_data['areaOfImpacts']).to be_empty
      expect(response_data['hasPreferences']).to be false
    end
  end

  describe 'when unauthenticated' do
    let(:context) { {} }

    it 'returns an authorization error' do
      expect(response_data).to be_nil
      expect(result['errors']).not_to be_empty
    end
  end
end
