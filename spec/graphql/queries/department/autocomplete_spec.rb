require 'rails_helper'

RSpec.describe Queries::Department::Autocomplete, type: :graphql do
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      query Autocomplete($q: String) {
        departmentAutocomplete(q: $q) { id name }
      }
    GQL
  end

  let(:result) { gql_execute(query, variables: variables, context: { current_user: user }) }
  let(:departments) { result.dig('data', 'departmentAutocomplete') }

  let(:admin) do
    User.create!(first_name: 'Admin', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :admin, confirmed_at: Time.current)
  end

  before { Current.user = admin }
  after { Current.reset }

  def create_department(name, approved: true)
    Department.create!(name: name, level: :national, is_approved: approved,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let!(:health) { create_department("Dept #{SecureRandom.hex(4)} Health") }
  let!(:finance) { create_department("Dept #{SecureRandom.hex(4)} Finance") }
  let!(:unapproved) { create_department("Dept #{SecureRandom.hex(4)} Unapproved", approved: false) }

  describe 'when signed in' do
    let(:variables) { {} }

    it 'lists approved departments alphabetically' do
      names = departments.map { |d| d['name'] }

      expect(names).to include(health.name, finance.name)
      expect(names).not_to include(unapproved.name)
      expect(names).to eq(names.sort)
    end

    it 'searches by name' do
      result = gql_execute(query, variables: { q: 'Health' }, context: { current_user: user })
      names = result.dig('data', 'departmentAutocomplete').map { |d| d['name'] }

      expect(names).to include(health.name)
      expect(names).not_to include(finance.name)
    end
  end

  describe 'when nobody is signed in' do
    let(:result) { gql_execute(query, variables: {}, context: {}) }

    it 'rejects the request' do
      expect(departments).to be_nil
      expect(result['errors']).not_to be_empty
    end
  end
end
