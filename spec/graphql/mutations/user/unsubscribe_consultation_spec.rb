require 'rails_helper'

RSpec.describe Mutations::User::UnsubscribeConsultation, type: :graphql do
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current,
                 notify_for_new_consultation: true)
  end

  let(:query) do
    <<~GQL
      mutation Unsubscribe($unsubscribeToken: String!) {
        unsubscribeConsultation(unsubscribeToken: $unsubscribeToken)
      }
    GQL
  end

  let(:variables) { { unsubscribeToken: user.uuid } }
  let(:result) { gql_execute(query, variables: variables, context: {}) }

  it 'turns off new-consultation notifications' do
    expect(result.dig('data', 'unsubscribeConsultation')).to be(true)
    expect(user.reload.notify_for_new_consultation).to be_falsey
  end

  describe 'with an unknown token' do
    let(:variables) { { unsubscribeToken: 'not-a-real-token' } }

    it 'rejects the request' do
      expect(result.dig('data', 'unsubscribeConsultation')).to be_nil
      expect(result['errors'].first['message']).to eq('Invalid Unsubscriber Token')
    end
  end
end
