require 'rails_helper'

# The story: A department drafts a consultation on a new waste policy and
# opens it to the public. A citizen joins Civis, reads the consultation,
# answers its questions and rates the experience. Another citizen joins,
# reads the answer and applauds it with an up-vote — then changes their
# mind and takes the vote back. When the deadline passes, the consultation
# expires and the platform publishes what the public said.
RSpec.describe 'The story of a consultation', type: :request do
  include GraphqlRequestHelpers

  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let(:admin) do
    User.create!(first_name: 'Admin', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :admin, confirmed_at: Time.current)
  end

  let(:citizen_email) { 'aarav@example.com' }
  let(:voter_email) { 'diya@example.com' }

  let(:sign_up_query) do
    <<~GQL
      mutation SignUp($auth: SignUp!) {
        authSignUp(auth: $auth) { accessToken expiresAt }
      }
    GQL
  end

  let(:login_query) do
    <<~GQL
      mutation AuthLogin($auth: Login!) {
        authLogin(auth: $auth)
      }
    GQL
  end

  let(:verify_otp_query) do
    <<~GQL
      mutation VerifyOtp($auth: VerifyOtp!) {
        verifyOtp(auth: $auth) { accessToken expiresAt }
      }
    GQL
  end

  let(:create_consultation_query) do
    <<~GQL
      mutation CreateConsultation($consultation: ConsultationCreateInput!) {
        consultationCreate(consultation: $consultation) {
          id
          title
          status
          createdBy { id }
        }
      }
    GQL
  end

  let(:list_consultations_query) do
    <<~GQL
      query ListConsultations {
        consultationList {
          data { id title status }
          paging { totalItems currentPage }
        }
      }
    GQL
  end

  let(:profile_query) do
    <<~GQL
      query GetProfile($id: Int!) {
        consultationProfile(id: $id) {
          id
          title
          status
          responseRounds {
            id
            roundNumber
            active
            questions { id questionText questionType isOptional }
          }
        }
      }
    GQL
  end

  let(:submit_response_query) do
    <<~GQL
      mutation SubmitResponse($response: ConsultationResponseCreateInput!) {
        consultationResponseCreate(consultationResponse: $response) {
          id
          visibility
          satisfactionRating
          roundNumber
          responseText
        }
      }
    GQL
  end

  let(:response_profile_query) do
    <<~GQL
      query GetResponse($id: Int!) {
        consultationResponseProfile(id: $id) {
          id
          responseText
          upVoteCount
          downVoteCount
          votedAs { id voteDirection }
        }
      }
    GQL
  end

  let(:vote_create_query) do
    <<~GQL
      mutation Vote($vote: VoteCreateInput!) {
        voteCreate(consultationResponseVote: $vote) { id voteDirection }
      }
    GQL
  end

  let(:vote_delete_query) do
    <<~GQL
      mutation Unvote($consultationResponseId: Int!) {
        voteDelete(consultationResponseId: $consultationResponseId)
      }
    GQL
  end

  let(:response_list_query) do
    <<~GQL
      query ListResponses($consultationFilter: Int) {
        consultationResponseList(consultationFilter: $consultationFilter, sort: created_at, sortDirection: asc) {
          data { id responseText }
          paging { totalItems }
        }
      }
    GQL
  end

  let(:summary_query) do
    <<~GQL
      query Summary($id: Int!) {
        consultationResponseSummary(id: $id) {
          totalResponses
          questions {
            questionText
            totalResponses
            optionBreakdown { optionText selectionCount percentage }
          }
        }
      }
    GQL
  end

  def join_civis(email)
    gql_post(sign_up_query, variables: {
               auth: { email: email, firstName: 'Citizen', password: 'Password@123' }
             })
    login_with_otp(email)
  end

  def login_with_otp(email)
    gql_post(login_query, variables: { auth: { email: email } })
    user = User.find_by(email: email)
    otp = user.otp_requests.active.last.otp.to_s
    gql_post(verify_otp_query, variables: { auth: { email: email, otp: otp } })
  end

  def open_consultation
    result = gql_post(create_consultation_query, user: admin, variables: {
                        consultation: {
                          departmentId: department.id,
                          title: 'Feedback on the new waste policy',
                          url: 'https://example.com/waste-policy.pdf',
                          responseDeadline: 10.days.from_now.utc.iso8601
                        }
                      })
    consultation = Consultation.find(result.dig('data', 'consultationCreate', 'id').to_i)
    consultation.publish
    consultation
  end

  def seed_questions(consultation)
    round = consultation.response_rounds.first
    support_question = round.questions.create!(
      question_text: 'Do you support this policy?', question_type: :multiple_choice,
      is_optional: false, sub_questions_attributes: [{ question_text: 'Yes' }, { question_text: 'No' }]
    )
    comment_question = round.questions.create!(
      question_text: 'Any comments?', question_type: :long_text, is_optional: true
    )
    [support_question, comment_question]
  end

  def cast_vote(response_id, direction, token)
    gql_post(vote_create_query, token: token, variables: {
               vote: { consultationResponseId: response_id, voteDirection: direction }
             })
  end

  def withdraw_vote(response_id, token)
    gql_post(vote_delete_query, token: token, variables: { consultationResponseId: response_id })
  end

  before do
    @citizen_token = join_civis(citizen_email).dig('data', 'verifyOtp', 'accessToken')
    @voter_token = join_civis(voter_email).dig('data', 'verifyOtp', 'accessToken')
  end

  it 'welcomes citizens with an access token once they verify the OTP' do
    expect(@citizen_token).to be_present
    expect(@voter_token).to be_present
    expect(User.find_by(email: citizen_email).confirmed_at).to be_present
  end

  describe 'when the department opens a consultation' do
    before do
      @consultation = open_consultation
      @support_question, @comment_question = seed_questions(@consultation)
    end

    it 'lists the consultation for the public' do
      result = gql_post(list_consultations_query)
      listed = result.dig('data', 'consultationList', 'data').find { |c| c['id'].to_i == @consultation.id }

      expect(listed['title']).to eq('Feedback on the new waste policy')
      expect(listed['status']).to eq('published')
    end

    it 'shows the open response round and its questions' do
      result = gql_post(profile_query, variables: { id: @consultation.id })
      profile = result.dig('data', 'consultationProfile')

      round = profile['responseRounds'].first
      expect(round['roundNumber']).to eq(1)
      expect(round['active']).to be(true)
      expect(round['questions'].map { |q| q['questionText'] })
        .to include('Do you support this policy?', 'Any comments?')
    end

    describe 'and a citizen answers the questions' do
      before do
        @submit_result = gql_post(submit_response_query, token: @citizen_token, variables: {
                                    response: {
                                      consultationId: @consultation.id,
                                      responseStatus: 0,
                                      visibility: 'shared',
                                      satisfactionRating: 'satisfied',
                                      responseText: 'I support this policy.',
                                      answers: [{ 'question_id' => @support_question.id.to_s,
                                                  'answer' => [@support_question.sub_questions.first.id] }]
                                    }
                                  })
        @response_id = @submit_result.dig('data', 'consultationResponseCreate', 'id').to_i
      end

      it 'records the response against the open round' do
        stored = ConsultationResponse.find(@response_id)

        expect(stored.user.email).to eq(citizen_email)
        expect(stored.response_round_id).to eq(@consultation.response_rounds.first.id)
        expect(stored.answers).to be_present
      end

      it 'returns the submitted response with its visibility and rating' do
        expect(@submit_result['errors']).to be_nil
        submitted = @submit_result.dig('data', 'consultationResponseCreate')
        expect(submitted['visibility']).to eq('shared')
        expect(submitted['satisfactionRating']).to eq('satisfied')
        expect(submitted['roundNumber']).to eq(1)
      end

      it 'lets the author read their own response' do
        result = gql_post(response_profile_query, token: @citizen_token, variables: { id: @response_id })
        profile = result.dig('data', 'consultationResponseProfile')

        expect(profile['upVoteCount']).to eq(0)
        expect(profile['votedAs']).to be_nil
      end

      describe 'and another citizen applauds the answer' do
        before do
          cast_vote(@response_id, 'up', @voter_token)
        end

        it 'counts the up-vote on the response' do
          result = gql_post(response_profile_query, token: @voter_token, variables: { id: @response_id })
          profile = result.dig('data', 'consultationResponseProfile')

          expect(profile['upVoteCount']).to eq(1)
          expect(profile['votedAs']['voteDirection']).to eq('up')
        end

        describe 'until the voter changes their mind' do
          before do
            withdraw_vote(@response_id, @voter_token)
          end

          it 'takes the vote back' do
            result = gql_post(response_profile_query, token: @voter_token, variables: { id: @response_id })
            profile = result.dig('data', 'consultationResponseProfile')

            expect(profile['upVoteCount']).to eq(0)
            expect(profile['votedAs']).to be_nil
          end
        end
      end

      describe 'when the deadline passes and the consultation expires' do
        before do
          @consultation.update_column(:response_deadline, 1.day.ago)
          @consultation.expire
        end

        it 'shows the shared response in the public response list' do
          result = gql_post(response_list_query, variables: { consultationFilter: @consultation.id })
          listed = result.dig('data', 'consultationResponseList')

          expect(listed['data'].map { |r| r['id'].to_i }).to include(@response_id)
          expect(listed['paging']['totalItems']).to eq(1)
        end

        it 'publishes what the public said' do
          result = gql_post(summary_query, variables: { id: @consultation.id })
          summary = result.dig('data', 'consultationResponseSummary')

          expect(summary['totalResponses']).to eq(1)

          support_summary = summary['questions'].find { |q| q['questionText'] == 'Do you support this policy?' }
          yes_breakdown = support_summary['optionBreakdown'].find { |o| o['optionText'] == 'Yes' }
          no_breakdown = support_summary['optionBreakdown'].find { |o| o['optionText'] == 'No' }
          expect(support_summary['totalResponses']).to eq(1)
          expect(yes_breakdown['selectionCount']).to eq(1)
          expect(yes_breakdown['percentage']).to eq(100.0)
          expect(no_breakdown['selectionCount']).to eq(0)

          comment_summary = summary['questions'].find { |q| q['questionText'] == 'Any comments?' }
          expect(comment_summary['totalResponses']).to eq(0)
        end
      end
    end
  end
end
