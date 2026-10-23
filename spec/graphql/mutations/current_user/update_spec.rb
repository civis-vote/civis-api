require 'rails_helper'

RSpec.describe Mutations::CurrentUser::Update, type: :graphql do
  let(:theme_a) { Theme.create!(name: "Theme A #{SecureRandom.hex(4)}") }
  let(:theme_b) { Theme.create!(name: "Theme B #{SecureRandom.hex(4)}") }
  let(:area_of_impact_a) { Constant.create!(name: "AoI A #{SecureRandom.hex(4)}", constant_type: :area_of_impact) }
  let(:area_of_impact_b) { Constant.create!(name: "AoI B #{SecureRandom.hex(4)}", constant_type: :area_of_impact) }
  let(:segment) { Constant.create!(name: "Segment #{SecureRandom.hex(4)}", constant_type: :segment) }
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      mutation UpdateUser($user: CurrentUserUpdateInput!) {
        currentUserUpdate(user: $user) {
          id
          firstName
          hasPreferences
        }
      }
    GQL
  end

  let(:context) { { current_user: user } }
  let(:result) { CivisApiSchema.execute(query, variables: variables, context: context) }
  let(:response_data) { result.dig('data', 'currentUserUpdate') }

  describe 'updating profile attributes' do
    let(:variables) { { user: { firstName: 'Updated' } } }

    it 'updates the profile' do
      expect(result['errors']).to be_nil
      expect(user.reload.first_name).to eq('Updated')
      expect(response_data['firstName']).to eq('Updated')
    end
  end

  describe 'setting preferences' do
    let(:variables) { { user: { themeIds: [theme_a.id, theme_b.id], areaOfImpactIds: [area_of_impact_a.id] } } }

    it 'stores preferred themes and areas of impact' do
      expect(result['errors']).to be_nil
      expect(user.reload.preferred_theme_ids).to match_array([theme_a.id, theme_b.id])
      expect(user.reload.area_of_impact_ids).to match_array([area_of_impact_a.id])
    end

    it 'returns hasPreferences true' do
      expect(response_data['hasPreferences']).to be true
    end

    it 'ignores constants that are not areas of impact' do
      variables[:user][:areaOfImpactIds] << segment.id

      result
      expect(user.reload.area_of_impact_ids).to match_array([area_of_impact_a.id])
    end
  end

  describe 'replacing preferences' do
    let(:variables) { { user: { themeIds: [theme_b.id], areaOfImpactIds: [area_of_impact_b.id] } } }

    before do
      user.preferred_theme_ids = [theme_a.id]
      user.user_preferences.create!(preferable: area_of_impact_a)
    end

    it 'replaces existing preferences' do
      result
      expect(user.reload.preferred_theme_ids).to eq([theme_b.id])
      expect(user.reload.area_of_impact_ids).to eq([area_of_impact_b.id])
    end

    it 'does not remove segment constant maps' do
      user.constant_maps.create!(constant: segment)

      result
      expect(user.reload.segments).to include(segment)
    end
  end

  describe 'clearing preferences' do
    let(:variables) { { user: { themeIds: [], areaOfImpactIds: [] } } }

    before { user.preferred_theme_ids = [theme_a.id] }

    it 'clears preferences and returns hasPreferences false' do
      expect(response_data['hasPreferences']).to be false
      expect(user.reload.preferred_theme_ids).to be_empty
    end
  end

  describe 'when unauthenticated' do
    let(:context) { {} }
    let(:variables) { { user: { themeIds: [theme_a.id] } } }

    it 'returns an authorization error' do
      expect(response_data).to be_nil
      expect(result['errors']).not_to be_empty
    end
  end
end
