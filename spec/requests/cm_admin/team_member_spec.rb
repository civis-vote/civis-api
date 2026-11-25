require "rails_helper"

RSpec.describe "Team member admin", type: :request do
  let!(:members) do
    [
      create(:team_member, name: "Asha Rao", member_type: :team),
      create(:team_member, name: "Vikram Sen", member_type: :advisory)
    ]
  end
  let(:member) { members.first }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists team members" do
      expect(cm_admin_index(TeamMember)).to list_records(*members)
    end

    it "finds a member by search" do
      expect(cm_admin_index(TeamMember, search: member.name)).to list_records(member)
    end
  end

  it "shows a team member" do
    expect(cm_admin_show(member)).to have_field(:name).with_value(member.name)
  end

  it "edits a team member" do
    expect(cm_admin_update(member, designation: "Chief Advisor")).to succeed
    expect(member.reload.designation).to eq("Chief Advisor")
  end
end
