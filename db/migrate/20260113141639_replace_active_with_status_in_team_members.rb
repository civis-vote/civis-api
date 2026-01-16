class ReplaceActiveWithStatusInTeamMembers < ActiveRecord::Migration[7.1]
  def change
    remove_column :team_members, :active
    add_column :team_members, :status, :integer, default: 1, null: false
    add_index :team_members, :status
  end
end
