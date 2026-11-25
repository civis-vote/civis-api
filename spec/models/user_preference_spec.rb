require 'rails_helper'

RSpec.describe UserPreference, type: :model do
  let(:user) { create(:user) }
  let(:theme) { Theme.create!(name: "Theme #{SecureRandom.hex(4)}") }

  it 'links a user to a preferable theme' do
    preference = UserPreference.create!(user:, preferable: theme)

    expect(preference.user).to eq(user)
    expect(user.preferred_themes).to include(theme)
  end

  it 'allows one preference per user and preferable' do
    UserPreference.create!(user:, preferable: theme)

    expect { UserPreference.create!(user:, preferable: theme) }
      .to raise_error(ActiveRecord::RecordInvalid, /already been taken/)
  end
end
