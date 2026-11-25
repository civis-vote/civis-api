require 'rails_helper'

RSpec.describe GameAction, type: :model do
  let(:user) { create(:user) }

  it 'records the action for a user' do
    action = GameAction.create!(user:, action: :consultation_shared)

    expect(action.user).to eq(user)
    expect(action.action).to eq('consultation_shared')
  end

  it 'awards points and links the point event' do
    action = GameAction.create!(user:, action: :commented)

    expect(action.reload.point_event).to be_present
    expect(user.point_events).to include(action.point_event)
  end

  it 'rejects unknown actions' do
    expect { GameAction.create!(user:, action: 'does_not_exist') }.to raise_error(ArgumentError)
  end
end
