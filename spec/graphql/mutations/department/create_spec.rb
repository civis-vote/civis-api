require 'rails_helper'

RSpec.describe Mutations::Department::Create, type: :graphql do
  let(:admin) do
    User.create!(first_name: 'Admin', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :admin, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      mutation CreateDepartment($department: Create!) {
        departmentCreate(department: $department) {
          id
          name
          level
        }
      }
    GQL
  end

  let(:variables) do
    { department: {
      name: 'Ministry of Health',
      level: 'national',
      logoFile: { filename: 'logo.png', content: Base64.encode64(File.binread(Rails.root.join('spec/fixtures/files/sample.png'))) },
      departmentContactsAttributes: [{ contactType: 'primary', email: 'primary@health.gov.in' }]
    } }
  end

  let(:result) { gql_execute(query, variables: variables, context: { current_user: admin }) }
  let(:created) { result.dig('data', 'departmentCreate') }

  before { Current.user = admin }
  after { Current.reset }

  it 'creates the department with a contact and a logo' do
    expect(result['errors']).to be_nil
    department = Department.find(created['id'])

    expect(department.name).to eq('Ministry of Health')
    expect(department.level).to eq('national')
    expect(department.created_by).to eq(admin)
    expect(department.primary_contact.email).to eq('primary@health.gov.in')
    expect(department.logo.attached?).to be(true)
  end

  describe 'when nobody is signed in' do
    let(:result) { gql_execute(query, variables: variables, context: {}) }

    before { Current.reset }

    # Documents a gap: `accessible?` is inert under GraphQL::Schema::Visibility,
    # so the mutation runs unauthenticated. Tighten once fixed.
    it 'still creates the department' do
      expect(result['errors']).to be_nil
      expect(Department.find(created['id']).created_by).to be_nil
    end
  end
end
