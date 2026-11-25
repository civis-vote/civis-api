require 'rails_helper'

RSpec.describe Queries::ConsultationResponse::List, type: :graphql do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let(:consultation) do
    consultation = Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                                        response_deadline: 10.days.from_now, question_flow: :question_list,
                                        visibility: :public_consultation)
    # Skip the publish callbacks (scoring needs a created_by with a city) — the list only cares about status.
    consultation.update_column(:status, Consultation.statuses[:published])
    consultation.update_column(:published_at, 5.days.ago)
    consultation
  end

  let(:other_consultation) do
    other = Consultation.create!(title: "Other #{SecureRandom.hex(4)}", department: department,
                                 response_deadline: 10.days.from_now, question_flow: :question_list,
                                 visibility: :public_consultation)
    other.update_column(:status, Consultation.statuses[:published])
    other.update_column(:published_at, 5.days.ago)
    other
  end

  let(:admin) do
    User.create!(first_name: 'Admin', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :admin, confirmed_at: Time.current)
  end

  before { Current.user = admin }
  after { Current.reset }

  def create_responder(email)
    User.create!(first_name: 'Test', last_name: 'User', email: email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let!(:shared_response) do
    ConsultationResponse.create!(user: create_responder(Faker::Internet.unique.email), consultation: consultation,
                                 response_round: consultation.response_rounds.last,
                                 visibility: :shared, response_status: :acceptable,
                                 response_text: 'A shared response')
  end

  let!(:anonymous_response) do
    ConsultationResponse.create!(user: create_responder(Faker::Internet.unique.email), consultation: consultation,
                                 response_round: consultation.response_rounds.last,
                                 visibility: :anonymous, response_status: :acceptable,
                                 response_text: 'An anonymous response')
  end

  let!(:off_platform_response) do
    ConsultationResponse.create!(consultation: consultation,
                                 response_round: consultation.response_rounds.last,
                                 visibility: :shared, response_status: :acceptable, source: :off_platform,
                                 response_text: 'An off-platform response')
  end

  let!(:response_on_other_consultation) do
    ConsultationResponse.create!(user: create_responder(Faker::Internet.unique.email), consultation: other_consultation,
                                 response_round: other_consultation.response_rounds.last,
                                 visibility: :shared, response_status: :acceptable,
                                 response_text: 'A response elsewhere')
  end

  let!(:private_consultation_response) do
    organisation = Organisation.create!(name: "Org #{SecureRandom.hex(4)}")
    private_consultation = Consultation.create!(title: "Private #{SecureRandom.hex(4)}", department: department,
                                                response_deadline: 10.days.from_now, question_flow: :question_list,
                                                status: :published, visibility: :private_consultation,
                                                organisation: organisation)
    ConsultationResponse.create!(user: create_responder(Faker::Internet.unique.email), consultation: private_consultation,
                                 response_round: private_consultation.response_rounds.last,
                                 visibility: :shared, response_status: :acceptable,
                                 response_text: 'A private-consultation response')
  end

  let(:query) do
    <<~GQL
      query ListResponses($consultationFilter: Int, $responseTextFilter: Boolean,
                          $responsesFrom: ConsultationResponseSource, $page: Int, $perPage: Int) {
        consultationResponseList(consultationFilter: $consultationFilter, responseTextFilter: $responseTextFilter,
                                 responsesFrom: $responsesFrom, page: $page, perPage: $perPage,
                                 sort: created_at, sortDirection: asc) {
          data { id responseText }
          paging { totalItems }
        }
      }
    GQL
  end

  let(:variables) { {} }
  let(:result) { gql_execute(query, variables: variables, context: {}) }
  let(:listed) { result.dig('data', 'consultationResponseList') }
  let(:listed_ids) { listed['data'].map { |r| r['id'].to_i } }

  it 'lists shared responses to public consultations only' do
    expect(listed_ids).to contain_exactly(shared_response.id, response_on_other_consultation.id)
  end

  it 'paginates' do
    result = gql_execute(query, variables: { consultationFilter: consultation.id, page: 1, perPage: 1 }, context: {})

    expect(result.dig('data', 'consultationResponseList', 'data').size).to eq(1)
    expect(result.dig('data', 'consultationResponseList', 'paging', 'totalItems')).to eq(1)
  end

  describe 'with filters' do
    it 'filters by consultation' do
      variables[:consultationFilter] = other_consultation.id
      expect(listed_ids).to eq([response_on_other_consultation.id])
    end

    it 'lists off-platform responses' do
      variables[:responsesFrom] = 'off_platform'
      expect(listed_ids).to eq([off_platform_response.id])
    end

    it 'filters by the presence of response text' do
      variables[:responseTextFilter] = false
      expect(listed_ids).to be_empty
    end
  end
end
