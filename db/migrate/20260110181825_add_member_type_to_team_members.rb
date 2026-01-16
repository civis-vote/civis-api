class AddMemberTypeToTeamMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :team_members, :member_type, :integer, default: 0, null: false
    add_index :team_members, :member_type
  end
end
