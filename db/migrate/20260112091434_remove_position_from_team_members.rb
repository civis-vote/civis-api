class RemovePositionFromTeamMembers < ActiveRecord::Migration[7.1]
  def change
    remove_column :team_members, :position, :integer
  end
end
