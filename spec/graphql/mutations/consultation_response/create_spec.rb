require 'rails_helper'

RSpec.describe Mutations::ConsultationResponse::Create, type: :graphql do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let(:consultation) do
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list,
                         status: :published, visibility: :public_consultation, published_at: 5.days.ago)
  end

  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  let(:query) do
    <<~GQL
      mutation SubmitResponse($response: ConsultationResponseCreateInput!) {
        consultationResponseCreate(consultationResponse: $response) {
          id
          visibility
          satisfactionRating
          roundNumber
          consultation { id }
        }
      }
    GQL
  end

  let(:context) { { current_user: user } }
  let(:result) { gql_execute(query, variables: variables, context: context) }
  let(:submitted) { result.dig('data', 'consultationResponseCreate') }

  let(:variables) do
    { response: {
      consultationId: consultation.id,
      responseStatus: 0,
      visibility: 'shared',
      responseText: 'I support this policy.',
      satisfactionRating: 'satisfied'
    } }
  end

  before { Current.user = user }
  after { Current.reset }

  describe 'when a citizen responds to an open consultation' do
    it 'stores the response against the latest round' do
      expect(result['errors']).to be_nil
      response = ConsultationResponse.find(submitted['id'])

      expect(response.user).to eq(user)
      expect(response.consultation).to eq(consultation)
      expect(response.response_round_id).to eq(consultation.response_rounds.last.id)
      expect(response.visibility).to eq('shared')
      expect(response.satisfaction_rating).to eq('satisfied')
      expect(submitted['roundNumber']).to eq(1)
    end
  end

  describe 'when the citizen is not signed in' do
    let(:context) { {} }

    it 'rejects the submission' do
      expect(submitted).to be_nil
      expect(result['errors'].first['message']).to eq(I18n.t('consultation_response.unauthorized'))
    end
  end

  describe 'when the consultation has passed its deadline' do
    before { consultation.update_column(:response_deadline, 1.day.ago) }

    it 'rejects the submission as expired' do
      expect(submitted).to be_nil
      expect(result['errors'].first['message']).to eq('Consultation Expired')
    end
  end

  describe 'when the citizen already responded to this round' do
    before do
      ConsultationResponse.create!(user: user, consultation: consultation,
                                   response_round: consultation.response_rounds.last,
                                   visibility: :shared, response_status: :acceptable)
    end

    it 'rejects the duplicate submission' do
      expect(submitted).to be_nil
      expect(result['errors'].first['message']).to eq('Response already submitted by User')
    end
  end

  describe 'when the round has a mandatory question' do
    before do
      consultation.response_rounds.last.questions.create!(
        question_text: 'Do you support this policy?', question_type: :multiple_choice,
        is_optional: false, sub_questions_attributes: [{ question_text: 'Yes' }, { question_text: 'No' }]
      )
    end

    it 'accepts a response that answers it' do
      variables[:response][:answers] = [{ 'question_id' => consultation.response_rounds.last.questions.first.id.to_s,
                                          'answer' => [consultation.response_rounds.last.questions.first.sub_questions.first.id] }]
      expect(result['errors']).to be_nil
      expect(ConsultationResponse.find(submitted['id']).answers).to be_present
    end

    it 'rejects a response that leaves it unanswered' do
      expect(submitted).to be_nil
      expect(result['errors'].first['message']).to include('Mandatory question')
    end
  end

  describe 'when the consultation is private and enforces private responses' do
    let(:organisation) { Organisation.create!(name: "Org #{SecureRandom.hex(4)}") }

    before do
      consultation.update!(visibility: :private_consultation, organisation: organisation, private_response: 1)
      Respondent.create!(user: user, response_round: consultation.response_rounds.last, organisation: organisation)
    end

    it 'rejects a shared response' do
      expect(submitted).to be_nil
      expect(result['errors'].first['message']).to eq("Private response is enforced, response visibility can't be shared")
    end

    it 'links the respondent when the response is anonymous' do
      variables[:response][:visibility] = 'anonymous'
      expect(result['errors']).to be_nil
      response = ConsultationResponse.find(submitted['id'])

      expect(response.visibility).to eq('anonymous')
      expect(response.respondent.user).to eq(user)
    end
  end

  describe 'when the citizen submits anonymously' do
    it 'stores the response as anonymous' do
      variables[:response][:visibility] = 'anonymous'
      expect(result['errors']).to be_nil
      expect(ConsultationResponse.find(submitted['id']).visibility).to eq('anonymous')
    end
  end

  describe 'when the citizen builds on someone else\'s response' do
    let(:template_author) do
      User.create!(first_name: 'Other', last_name: 'User', email: Faker::Internet.unique.email,
                   password: 'Password@123', role: :citizen, confirmed_at: Time.current)
    end

    before do
      @template = ConsultationResponse.create!(user: template_author, consultation: consultation,
                                               response_round: consultation.response_rounds.last,
                                               visibility: :shared, response_status: :acceptable,
                                               response_text: 'A well-argued response')
      variables[:response][:templateId] = @template.id
    end

    it 'links the template' do
      expect(result['errors']).to be_nil
      response = ConsultationResponse.find(submitted['id'])

      expect(response.template_id).to eq(@template.id)
    end
  end

  describe 'when the citizen leaves feedback on clauses' do
    let!(:clause) do
      Clause.create!(consultation: consultation, clause_id: SecureRandom.hex(4),
                     clause_title: "Clause #{SecureRandom.hex(4)}")
    end
    let!(:other_clause) do
      other = Consultation.create!(title: "Other #{SecureRandom.hex(4)}", department: department,
                                   response_deadline: 10.days.from_now, question_flow: :question_list)
      Clause.create!(consultation: other, clause_id: SecureRandom.hex(4), clause_title: "Other #{SecureRandom.hex(4)}")
    end

    before do
      variables[:response][:clauseFeedbacks] = [
        { clauseId: clause.id, feedbackComment: 'Unclear wording', feedbackReason: 'Definition too broad' },
        { clauseId: other_clause.id, feedbackComment: 'Should be ignored' }
      ]
    end

    it 'records feedback only for this consultation\'s clauses' do
      expect(result['errors']).to be_nil
      response = ConsultationResponse.find(submitted['id'])

      expect(response.clause_feedbacks.count).to eq(1)
      expect(response.clause_feedbacks.first.clause_id).to eq(clause.id)
      expect(response.clause_feedbacks.first.feedback_comment.to_plain_text).to eq('Unclear wording')
    end
  end
end
