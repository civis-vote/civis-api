require 'rails_helper'

RSpec.describe Mutations::Consultation::Create, type: :graphql do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let(:admin) do
    User.create!(first_name: 'Admin', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :admin, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      mutation CreateConsultation($consultation: ConsultationCreateInput!) {
        consultationCreate(consultation: $consultation) {
          id
          title
          status
          createdBy { id }
          department { id }
        }
      }
    GQL
  end

  let(:variables) do
    { consultation: {
      departmentId: department.id,
      title: 'Feedback on the new waste policy',
      url: 'https://example.com/waste-policy.pdf',
      responseDeadline: 10.days.from_now.utc.iso8601
    } }
  end

  let(:result) { gql_execute(query, variables: variables, context: { current_user: admin }) }
  let(:created) { result.dig('data', 'consultationCreate') }

  before { Current.user = admin }
  after { Current.reset }

  it 'creates a submitted consultation owned by the signed-in user' do
    expect(result['errors']).to be_nil
    consultation = Consultation.find(created['id'])

    expect(consultation.title).to eq('Feedback on the new waste policy')
    expect(consultation.status).to eq('submitted')
    expect(consultation.department).to eq(department)
    expect(consultation.created_by).to eq(admin)
    expect(created.dig('createdBy', 'id').to_i).to eq(admin.id)
  end

  it 'opens the first response round' do
    expect { result }.to change { ResponseRound.count }.by(1)
  end

  describe 'when nobody is signed in' do
    let(:result) { gql_execute(query, variables: variables, context: {}) }

    before { Current.reset }

    # Documents a gap: `accessible?` is inert under GraphQL::Schema::Visibility, so the
    # mutation runs unauthenticated and stamps no created_by. Tighten once fixed.
    it 'still creates the consultation, without an owner' do
      expect(result['errors']).to be_nil
      consultation = Consultation.find(created['id'])

      expect(consultation.created_by).to be_nil
    end
  end
end
