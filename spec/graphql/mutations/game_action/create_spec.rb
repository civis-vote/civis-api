require 'rails_helper'

RSpec.describe Mutations::GameAction::Create, type: :graphql do
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      mutation CreateGameAction($gameAction: GameActionCreateInput!) {
        gameActionCreate(gameAction: $gameAction) {
          id
          pointEvent { id }
        }
      }
    GQL
  end

  let(:variables) { { gameAction: { action: 'consultation_shared' } } }
  let(:result) { gql_execute(query, variables: variables, context: { current_user: user }) }
  let(:created) { result.dig('data', 'gameActionCreate') }

  it 'records the action for the signed-in user' do
    expect(result['errors']).to be_nil
    action = GameAction.find(created['id'])

    expect(action.user).to eq(user)
    expect(action.action).to eq('consultation_shared')
  end

  it 'awards points for the action' do
    expect { result }.to change { user.point_events.count }.by(1)
  end

  describe 'when nobody is signed in' do
    let(:result) { gql_execute(query, variables: variables, context: {}) }

    it 'rejects the action' do
      expect(created).to be_nil
      expect(result['errors']).not_to be_empty
    end
  end
end
