class CreateTeamMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :team_members do |t|
      t.string :name
      t.string :designation
      t.boolean :active
      t.integer :position

      t.timestamps
    end
  end
end
