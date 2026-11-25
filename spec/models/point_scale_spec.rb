require 'rails_helper'

RSpec.describe PointScale, type: :model do
  it 'maps actions to point values' do
    scale = PointScale.create!(action: :response_submitted, points: 10, upper_limit: 100)

    expect(scale.action).to eq('response_submitted')
    expect(scale.points).to eq(10)
  end

  it 'only accepts known actions' do
    expect { PointScale.new(action: 'unknown_action') }.to raise_error(ArgumentError)
  end

  it 'awards points to a user through a point event' do
    PointScale.create!(action: :consultation_shared, points: 5, upper_limit: 100)
    user = create(:user)

    expect { user.add_points(:consultation_shared) }.to change { user.point_events.count }.by(1)

    point_event = user.point_events.last
    expect(point_event.user).to eq(user)
    expect(point_event.point_scale.action).to eq('consultation_shared')
  end
end
