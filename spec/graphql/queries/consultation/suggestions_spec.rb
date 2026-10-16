require 'rails_helper'

RSpec.describe Queries::Consultation::Suggestions, type: :graphql do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end
  let(:theme) { Theme.create!(name: "Theme #{SecureRandom.hex(4)}") }
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      query ConsultationSuggestions($consultationId: Int, $limit: Int) {
        consultationSuggestions(consultationId: $consultationId, limit: $limit) {
          id
          title
        }
      }
    GQL
  end

  before { Current.user = user }
  after { Current.reset }

  def create_consultation(theme: nil, deadline: 10.days.from_now)
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         theme: theme, response_deadline: deadline, question_flow: :question_list,
                         status: :published, visibility: :public_consultation, published_at: 5.days.ago)
  end

  describe 'when authenticated' do
    let(:context) { { current_user: user } }

    it 'returns open public consultations' do
      consultation = create_consultation

      result = CivisApiSchema.execute(query, context: context)
      suggestions = result.dig('data', 'consultationSuggestions')

      expect(result['errors']).to be_nil
      expect(suggestions.map { |s| s['id'].to_i }).to include(consultation.id)
    end

    it 'respects the limit argument' do
      5.times { create_consultation }

      result = CivisApiSchema.execute(query, variables: { limit: 2 }, context: context)
      suggestions = result.dig('data', 'consultationSuggestions')

      expect(suggestions.size).to eq(2)
    end

    it 'ranks same-theme consultations first when consultationId is given' do
      source = create_consultation(theme: theme)
      same_theme = create_consultation(theme: theme)
      other_theme = create_consultation

      result = CivisApiSchema.execute(query, variables: { consultationId: source.id }, context: context)
      ids = result.dig('data', 'consultationSuggestions').map { |s| s['id'].to_i }

      expect(ids.first).to eq(same_theme.id)
      expect(ids).to include(other_theme.id)
      expect(ids).not_to include(source.id)
    end
  end

  describe 'when unauthenticated' do
    it 'returns an authorization error' do
      create_consultation

      result = CivisApiSchema.execute(query, context: {})

      expect(result.dig('data', 'consultationSuggestions')).to be_nil
      expect(result['errors']).not_to be_empty
    end
  end
end
