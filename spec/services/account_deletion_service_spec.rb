require 'rails_helper'

RSpec.describe AccountDeletionService do
  let(:state) { Location.create!(name: 'Test State', location_type: :state) }
  let(:city) { Location.create!(name: 'Test City', location_type: :city, parent: state) }
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end

  let!(:point_scales) do
    {
      user_created: PointScale.create!(action: :user_created, points: 5, upper_limit: 100),
      response_submitted: PointScale.create!(action: :response_submitted, points: 10, upper_limit: 100),
      commented: PointScale.create!(action: :commented, points: 10, upper_limit: 100)
    }
  end

  let!(:user) { create_user(city: city) }
  let!(:other_user) { create_user(city: city) }

  let!(:consultation) do
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list)
  end

  let!(:response) { create_response(user: user, response_text: 'My response text') }
  let!(:response_with_voice) do
    r = create_response(user: user, visibility: :anonymous, response_text: 'Voice response text')
    r.voice_messages.attach(io: StringIO.new('hello voice'), filename: 'voice.mp3', content_type: 'audio/mpeg')
    r
  end
  let!(:other_response) { create_response(user: other_user, response_text: 'Other response text') }
  let!(:template_child) { create_response(user: other_user, response_text: 'Template child text', template: response) }

  let!(:clause) { Clause.create!(consultation: consultation, clause_id: 'C-1', clause_title: 'Clause one') }
  let!(:clause_feedback) { ClauseFeedback.create!(clause: clause, consultation_response: response) }

  let!(:vote_on_own_response) do
    ConsultationResponseVote.create!(user: other_user, consultation_response: response, vote_direction: :down)
  end
  let!(:vote_on_other_response) do
    ConsultationResponseVote.create!(user: user, consultation_response: other_response, vote_direction: :up)
  end

  let!(:point_event) { PointEvent.create!(user: user, point_scale: point_scales[:response_submitted], points: 10) }
  let!(:game_action) { GameAction.create!(user: user, action: :commented) }

  let!(:notification_setting) { NotificationSetting.create!(user: user, on_new_consultation: true) }
  let!(:respondent) { Respondent.create!(user: user, response_round: consultation.response_rounds.first) }
  let!(:user_count) { UserCount.create!(user_id: user.id, profanity_count: 2) }
  let!(:ct_page_view) { CtPageView.create!(owner: user, name: 'Default view', ar_model_name: 'User') }

  let!(:created_consultation) do
    c = Consultation.create!(title: "Created consultation #{SecureRandom.hex(4)}", department: department,
                             response_deadline: 10.days.from_now, question_flow: :question_list)
    c.update_column(:created_by_id, user.id)
    c
  end
  let!(:created_department) do
    d = Department.create!(name: "Created dept #{SecureRandom.hex(4)}", level: :national,
                           department_contacts_attributes: [{ contact_type: :primary, email: 'dept2@test.com' }])
    d.update_column(:created_by_id, user.id)
    d
  end
  let!(:created_organisation) do
    Current.set(user: user) do
      Organisation.create!(name: "Created org #{SecureRandom.hex(4)}")
    end
  end
  let!(:created_case_study) do
    Current.set(user: user) do
      CaseStudy.create!(name: "Created case study #{SecureRandom.hex(4)}")
    end
  end
  let!(:created_profanity) do
    Current.set(user: user) do
      Profanity.create!(profane_word: "profanity_#{SecureRandom.hex(4)}")
    end
  end
  let!(:created_wordindex) do
    Current.set(user: user) do
      Wordindex.create!(word: "word_#{SecureRandom.hex(4)}")
    end
  end
  let!(:created_showcase_slide) do
    s = Fabricate(:showcase_slide)
    s.update_column(:created_by_id, user.id)
    s
  end
  let!(:created_support_ticket) do
    t = CmSupportTicket.new(name: 'Ticket', description: 'Support needed')
    t.save!(validate: false)
    t.update_column(:created_by_id, user.id)
    t
  end
  let!(:created_platform_setting) do
    CmPlatformSetting.create!(name: "Setting #{SecureRandom.hex(4)}", slug: "setting_#{SecureRandom.hex(4)}", created_by: user)
  end

  let!(:api_token) { user.api_tokens.create!(token_type: :access, token: SecureRandom.hex(16)) }
  let!(:otp_request) { OtpRequest.create!(user: user, otp: 123_456) }
  let!(:profile_picture) do
    user.profile_picture.attach(io: StringIO.new('avatar'), filename: 'avatar.png', content_type: 'image/png')
    user.profile_picture
  end

  let(:service) { described_class.new(user) }

  def create_user(attrs = {})
    User.create!({
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      email: Faker::Internet.unique.email,
      password: 'Password@123',
      role: :citizen,
      confirmed_at: Time.current
    }.merge(attrs))
  end

  def create_response(user:, response_text:, **attrs)
    round = ResponseRound.create!(consultation: consultation)
    ConsultationResponse.create!({
      user: user,
      consultation: consultation,
      response_round: round,
      visibility: :shared,
      response_status: :acceptable,
      response_text: response_text
    }.merge(attrs))
  end

  describe '#call' do
    it 'returns true' do
      expect(service.call).to be true
    end

    it 'hard deletes the user consultation responses with rich text, attachments, clause feedbacks and votes' do
      expect(ConsultationResponse.unscoped.where(user_id: user.id).count).to eq(2)
      service.call

      expect(ConsultationResponse.unscoped.where(user_id: user.id)).to be_empty
      expect(ConsultationResponse.unscoped.where(consultation_id: consultation.id, user_id: [user.id, other_user.id]).count).to eq(2)

      response_ids = [response.id, response_with_voice.id]
      expect(ActionText::RichText.where(record_type: 'ConsultationResponse', record_id: response_ids)).to be_empty
      expect(ActiveStorage::Attachment.where(record_type: 'ConsultationResponse', record_id: response_ids)).to be_empty
      expect(ClauseFeedback.where(consultation_response_id: response_ids)).to be_empty
      expect(ConsultationResponseVote.where(consultation_response_id: response_ids)).to be_empty
    end

    it 'detaches responses used as templates before deleting them' do
      expect(template_child.reload.template_id).to eq(response.id)
      service.call

      expect(template_child.reload.template_id).to be_nil
      expect(ConsultationResponse.unscoped.exists?(template_child.id)).to be true
    end

    it 'keeps the consultation counter cache consistent' do
      expect(consultation.reload.consultation_responses_count).to eq(4)
      service.call

      expect(consultation.reload.consultation_responses_count).to eq(2)
    end

    it 'deletes votes the user cast on other responses and refreshes the vote counters' do
      expect(other_response.reload.up_vote_count).to eq(1)
      service.call

      expect(ConsultationResponseVote.where(id: vote_on_other_response.id)).to be_empty
      expect(other_response.reload.up_vote_count).to eq(0)
    end

    it 'deletes votes on soft-deleted responses without failing' do
      doomed_response = create_response(user: other_user, response_text: 'Doomed text')
      doomed_vote = ConsultationResponseVote.create!(user: user, consultation_response: doomed_response,
                                                     vote_direction: :up)
      doomed_response.destroy

      expect { service.call }.not_to raise_error

      expect(ConsultationResponseVote.where(id: doomed_vote.id)).to be_empty
      expect(User.exists?(user.id)).to be false
    end

    it 'deletes the point events and game actions' do
      expect(PointEvent.where(user_id: user.id)).not_to be_empty
      expect(GameAction.where(user_id: user.id)).not_to be_empty

      service.call

      expect(PointEvent.where(user_id: user.id)).to be_empty
      expect(GameAction.where(user_id: user.id)).to be_empty
    end

    it 'recomputes the leaderboard ranks of remaining users' do
      # Use high point values so the assertions are not affected by any other
      # citizens that may exist in the database.
      user.update_columns(points: 500.0, rank: 1, state_rank: 1, city_rank: 1)
      other_user.update_columns(points: 400.0, rank: 2, state_rank: 2, city_rank: 2)

      service.call

      other_user.reload
      expect(other_user.rank).to eq(1)
      expect(other_user.state_rank).to eq(1)
      expect(other_user.city_rank).to eq(1)
    end

    it 'deletes the notification settings, respondents, user counts and ct page views' do
      service.call

      expect(NotificationSetting.where(user_id: user.id)).to be_empty
      expect(Respondent.where(user_id: user.id)).to be_empty
      expect(UserCount.where(user_id: user.id)).to be_empty
      expect(CtPageView.where(owner: user)).to be_empty
    end

    it 'nullifies invited_by references on users invited by the deleted user' do
      invited_user = create_user(city: city)
      invited_user.update_columns(invited_by_type: 'User', invited_by_id: user.id)

      service.call

      expect(invited_user.reload.invited_by_id).to be_nil
      expect(invited_user.reload.invited_by_type).to be_nil
    end

    it 'nullifies created_by references on content kept in the system' do
      service.call

      expect(created_consultation.reload.created_by_id).to be_nil
      expect(created_department.reload.created_by_id).to be_nil
      expect(created_organisation.reload.created_by_id).to be_nil
      expect(created_case_study.reload.created_by_id).to be_nil
      expect(created_profanity.reload.created_by_id).to be_nil
      expect(created_wordindex.reload.created_by_id).to be_nil
      expect(created_showcase_slide.reload.created_by_id).to be_nil
      expect(created_support_ticket.reload.created_by_id).to be_nil
      expect(created_platform_setting.reload.created_by_id).to be_nil
      expect(created_platform_setting.reload.created_by_type).to be_nil
    end

    it 'deletes the user profile with its dependent records and profile picture' do
      expect(User.exists?(user.id)).to be true
      service.call

      expect(User.exists?(user.id)).to be false
      expect(OtpRequest.where(user_id: user.id)).to be_empty
      expect(ApiToken.where(user_id: user.id)).to be_empty
      expect(ActiveStorage::Attachment.where(record_type: 'User', record_id: user.id)).to be_empty
    end

    it 'rolls back all changes when a step fails' do
      allow_any_instance_of(AccountDeletionService).to receive(:delete_consultation_responses).and_raise(StandardError, 'boom')

      expect { service.call }.to raise_error(StandardError, 'boom')

      expect(User.exists?(user.id)).to be true
      expect(ConsultationResponse.unscoped.exists?(response.id)).to be true
      expect(PointEvent.where(user_id: user.id)).not_to be_empty
      expect(created_consultation.reload.created_by_id).to eq(user.id)
    end
  end
end
