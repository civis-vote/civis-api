require 'rails_helper'

RSpec.describe Queries::User::List, type: :graphql do
  let(:city) { Location.create!(name: "City #{SecureRandom.hex(4)}", location_type: :city) }
  let(:state) { Location.create!(name: "State #{SecureRandom.hex(4)}", location_type: :state) }

  def create_user(role, city: nil)
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: role, confirmed_at: Time.current, city: city)
  end

  let!(:citizen) { create_user(:citizen) }
  # set_cm_role forces role: citizen unless a cm_role is present, so hand the admin its role.
  let!(:admin) do
    User.create!(first_name: 'Admin', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :admin, confirmed_at: Time.current,
                 cm_role: CmRole.create!(name: 'Admin'))
  end
  let!(:city_citizen) { create_user(:citizen, city: city) }

  let(:query) do
    <<~GQL
      query ListUsers($roleFilter: [UserRoles!], $locationFilter: Int, $page: Int, $perPage: Int) {
        userList(roleFilter: $roleFilter, locationFilter: $locationFilter, page: $page, perPage: $perPage,
             sort: created_at, sortDirection: asc) {
          data { id firstName points }
          paging { totalItems }
        }
      }
    GQL
  end

  let(:variables) { {} }
  let(:result) { gql_execute(query, variables: variables, context: {}) }
  let(:listed) { result.dig('data', 'userList') }
  let(:listed_ids) { listed['data'].map { |u| u['id'].to_i } }

  it 'lists all users' do
    expect(listed_ids).to contain_exactly(citizen.id, admin.id, city_citizen.id)
  end

  it 'paginates' do
    result = gql_execute(query, variables: { page: 1, perPage: 2 }, context: {})

    expect(result.dig('data', 'userList', 'data').size).to eq(2)
    expect(result.dig('data', 'userList', 'paging', 'totalItems')).to eq(3)
  end

  describe 'with filters' do
    it 'filters by role' do
      variables[:roleFilter] = ['admin']
      expect(listed_ids).to eq([admin.id])
    end

    it 'filters by location, including its children' do
      variables[:locationFilter] = state.id
      expect(listed_ids).to be_empty
    end
  end
end
