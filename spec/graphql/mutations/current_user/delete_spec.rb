require 'rails_helper'

RSpec.describe Mutations::CurrentUser::Delete, type: :graphql do
  let(:query) do
    <<~GQL
      mutation DeleteAccount {
        deleteAccount
      }
    GQL
  end

  let!(:user) do
    User.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name,
                 email: Faker::Internet.unique.email, password: 'Password@123', role: :citizen,
                 confirmed_at: Time.current)
  end

  let(:context) { { current_user: user } }

  let(:result) do
    CivisApiSchema.execute(query, context: context)
  end

  describe 'deleteAccount mutation' do
    it 'deletes the current user account and returns true' do
      expect(User.exists?(user.id)).to be true

      expect(result.dig('data', 'deleteAccount')).to be true
      expect(result['errors']).to be_nil
      expect(User.exists?(user.id)).to be false
    end

    it 'returns an error when the user is not authenticated' do
      result = CivisApiSchema.execute(query, context: {})

      expect(result.dig('data', 'deleteAccount')).to be_nil
      expect(result['errors']).not_to be_empty
      expect(User.exists?(user.id)).to be true
    end
  end
end
