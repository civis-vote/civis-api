require 'rails_helper'

RSpec.describe Queries::ConsultationResponse::Profile, type: :graphql do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let(:consultation) do
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list)
  end

  let(:author) do
    User.create!(first_name: 'Author', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:stranger) do
    User.create!(first_name: 'Stranger', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      query GetResponse($id: Int!) {
        consultationResponseProfile(id: $id) {
          id
          responseText
          visibility
          user { id }
        }
      }
    GQL
  end

  let(:variables) { { id: response.id } }
  let(:result) { gql_execute(query, variables: variables, context: { current_user: stranger }) }
  let(:profile) { result.dig('data', 'consultationResponseProfile') }

  describe 'when the response is shared' do
    let(:response) do
      ConsultationResponse.create!(user: author, consultation: consultation,
                                   response_round: consultation.response_rounds.last,
                                   visibility: :shared, response_status: :acceptable,
                                   response_text: 'A shared response')
    end

    it 'is readable by anyone' do
      result = gql_execute(query, variables: variables, context: { current_user: stranger })

      expect(result.dig('data', 'consultationResponseProfile', 'id').to_i).to eq(response.id)
    end

    it 'is readable without signing in, and exposes its verified author' do
      result = gql_execute(query, variables: variables, context: {})

      expect(result.dig('data', 'consultationResponseProfile', 'id').to_i).to eq(response.id)
      expect(result.dig('data', 'consultationResponseProfile', 'user', 'id').to_i).to eq(author.id)
    end
  end

  describe 'when the response is anonymous' do
    let(:response) do
      ConsultationResponse.create!(user: author, consultation: consultation,
                                   response_round: consultation.response_rounds.last,
                                   visibility: :anonymous, response_status: :acceptable,
                                   response_text: 'An anonymous response')
    end

    it 'is readable by its author' do
      viewer = author
      result = gql_execute(query, variables: variables, context: { current_user: viewer })

      expect(result.dig('data', 'consultationResponseProfile', 'id').to_i).to eq(response.id)
    end

    it 'stays hidden from everyone else' do
      result = gql_execute(query, variables: variables, context: { current_user: stranger })

      expect(profile).to be_nil
      expect(result['errors'].first['message']).to eq('User is not authorized to perform this action')
    end
  end
end
