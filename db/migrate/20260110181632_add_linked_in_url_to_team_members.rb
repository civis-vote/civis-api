class AddLinkedInUrlToTeamMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :team_members, :linkedin_url, :string
  end
end
