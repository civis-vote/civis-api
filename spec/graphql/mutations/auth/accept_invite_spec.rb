require 'rails_helper'

RSpec.describe Mutations::Auth::AcceptInvite, type: :graphql do
  let!(:city) { Location.find_or_create_by!(name: 'Test City', location_type: :city) }
  let!(:point_scale) { PointScale.find_or_create_by!(action: :user_created, points: 10, upper_limit: 100) }
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end
  let(:consultation) do
    Consultation.create!(title: 'Test Consultation', department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list)
  end
  let(:invited_user) { User.invite!(email: Faker::Internet.unique.email, skip_invitation: true) }
  let(:invitation_token) { invited_user.raw_invitation_token }

  let(:query) do
    <<~GQL
      mutation AcceptInvite($auth: AcceptInvite!) {
        authAcceptInvite(auth: $auth) {
          accessToken
        }
      }
    GQL
  end

  let(:result) { CivisApiSchema.execute(query, variables: { auth: auth_input }) }
  let(:response_data) { result.dig('data', 'authAcceptInvite') }

  let(:base_auth) do
    { firstName: 'Invited', invitationToken: invitation_token, consultationId: consultation.id }
  end

  describe 'accepting an invite without a password' do
    let(:auth_input) { base_auth }

    it 'accepts the invitation and returns an api key' do
      expect(result['errors']).to be_nil
      expect(response_data['accessToken']).to be_present
      expect(invited_user.reload.invitation_accepted_at).to be_present
    end
  end

  describe 'accepting an invite with a password' do
    let(:auth_input) { base_auth.merge(password: 'Password@123') }

    it 'accepts the invitation' do
      expect(result['errors']).to be_nil
      expect(invited_user.reload.invitation_accepted_at).to be_present
      expect(invited_user.valid_password?('Password@123')).to be true
    end
  end

  describe 'when the invitation token is invalid' do
    let(:auth_input) { base_auth.merge(invitationToken: 'bogus') }

    it 'returns an error' do
      expect(result['errors']).not_to be_nil
    end
  end

  describe 'when the invitation has already been accepted' do
    let(:auth_input) { base_auth }

    it 'returns an error on replay' do
      expect(result['errors']).to be_nil
      expect(invited_user.reload.invitation_accepted_at).to be_present

      replay = CivisApiSchema.execute(query, variables: { auth: auth_input })
      expect(replay['errors']).not_to be_nil
    end
  end

  describe 'when the consultation deadline has passed' do
    let(:consultation) do
      Consultation.create!(title: 'Expired', department: department,
                           response_deadline: 2.days.ago, question_flow: :question_list)
    end
    let(:auth_input) { base_auth }

    it 'returns an error' do
      expect(result['errors']).not_to be_nil
    end
  end
end
