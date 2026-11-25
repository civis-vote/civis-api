require 'rails_helper'

RSpec.describe Queries::Consultation::List, type: :graphql do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let(:other_department) do
    Department.create!(name: "Other #{SecureRandom.hex(4)}", level: :state,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'other@test.com' }])
  end

  let(:theme) { Theme.create!(name: "Theme #{SecureRandom.hex(4)}") }

  let(:admin) do
    User.create!(first_name: 'Admin', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :admin, confirmed_at: Time.current)
  end

  let(:organisation) { Organisation.create!(name: "Org #{SecureRandom.hex(4)}") }

  before { Current.user = admin }
  after { Current.reset }

  def create_consultation(attrs = {})
    status = attrs.delete(:status)
    consultation = Consultation.create!({ title: "Consultation #{SecureRandom.hex(4)}", department: department,
                                          response_deadline: 10.days.from_now,
                                          question_flow: :question_list }.merge(attrs))
    # Skip the publish callbacks (scoring needs a created_by with a city) — the list only cares about status.
    consultation.update_column(:status, Consultation.statuses[status]) if status
    consultation
  end

  let!(:published) { create_consultation(status: :published, visibility: :public_consultation, published_at: 5.days.ago) }
  let!(:private_one) { create_consultation(status: :published, visibility: :private_consultation, organisation: organisation) }
  let!(:in_other_department) { create_consultation(status: :published, department: other_department) }
  let!(:with_theme) { create_consultation(status: :published, theme: theme) }
  let!(:featured_one) { create_consultation(status: :published, is_featured: true) }
  let!(:searchable) { create_consultation(status: :published, title: 'Waste management rules') }
  let!(:submitted_one) { create_consultation(status: :submitted) }

  let(:query) do
    <<~GQL
      query ListConsultations(
        $statusFilter: String, $departmentFilter: Int, $themeFilter: Int,
        $featuredFilter: Boolean, $searchFilter: String, $sort: ConsultationSorts,
        $sortDirection: SortDirections, $page: Int, $perPage: Int
      ) {
        consultationList(
          statusFilter: $statusFilter, departmentFilter: $departmentFilter, themeFilter: $themeFilter,
          featuredFilter: $featuredFilter, searchFilter: $searchFilter, sort: $sort,
          sortDirection: $sortDirection, page: $page, perPage: $perPage
        ) {
          data { id title status }
          paging { totalItems }
        }
      }
    GQL
  end

  let(:variables) { {} }
  let(:result) { gql_execute(query, variables: variables, context: {}) }
  let(:listed) { result.dig('data', 'consultationList') }
  let(:listed_ids) { listed['data'].map { |c| c['id'].to_i } }

  it 'lists public consultations only' do
    expect(listed_ids).to include(published.id, in_other_department.id, with_theme.id,
                                  featured_one.id, searchable.id, submitted_one.id)
    expect(listed_ids).not_to include(private_one.id)
  end

  it 'paginates' do
    result = gql_execute(query, variables: { page: 1, perPage: 2 }, context: {})

    expect(result.dig('data', 'consultationList', 'data').size).to eq(2)
    expect(result.dig('data', 'consultationList', 'paging', 'totalItems')).to eq(6)
  end

  describe 'with filters' do
    it 'filters by department' do
      variables[:departmentFilter] = other_department.id
      expect(listed_ids).to eq([in_other_department.id])
    end

    it 'filters by theme' do
      variables[:themeFilter] = theme.id
      expect(listed_ids).to eq([with_theme.id])
    end

    it 'filters by status' do
      variables[:statusFilter] = 'submitted'
      expect(listed_ids).to eq([submitted_one.id])
    end

    it 'filters by featured' do
      variables[:featuredFilter] = true
      expect(listed_ids).to eq([featured_one.id])
    end

    it 'searches by title' do
      variables[:searchFilter] = 'waste'
      expect(listed_ids).to eq([searchable.id])
    end
  end

  describe 'with sorting' do
    it 'orders by response deadline' do
      urgent = create_consultation(status: :published, response_deadline: 1.day.from_now)

      result = gql_execute(query, variables: { sort: 'response_deadline', sortDirection: 'asc' }, context: {})
      ids = result.dig('data', 'consultationList', 'data').map { |c| c['id'].to_i }

      expect(ids.first).to eq(urgent.id)
    end
  end
end
