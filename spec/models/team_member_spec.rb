require 'rails_helper'

RSpec.describe TeamMember, type: :model do
  def create_member(attrs = {})
    member = build(:team_member, **attrs)
    member.save!
    member
  end

  describe 'validations' do
    it 'needs a name, designation and profile picture' do
      expect(TeamMember.new).not_to be_valid
    end

    it 'rejects a non-image profile picture' do
      member = build(:team_member)
      member.profile_picture.attach(io: StringIO.new('text'), filename: 'notes.txt',
                                    content_type: 'text/plain')

      expect(member).not_to be_valid
      expect(member.errors[:profile_picture]).to include('must be a JPG or PNG image')
    end
  end

  describe 'scopes' do
    it 'lists active members only' do
      active = create_member
      create_member(status: :inactive)

      expect(TeamMember.active_only).to contain_exactly(active)
    end

    it 'filters by member type' do
      team_member = create_member(member_type: :team)
      create_member(member_type: :advisory)

      expect(TeamMember.member_type_filter('team')).to contain_exactly(team_member)
    end
  end
end
