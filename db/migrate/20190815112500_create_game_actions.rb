class CreateGameActions < ActiveRecord::Migration[6.0]
  def change
    create_table :game_actions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :action
      t.references :point_event, foreign_key: true

      t.timestamps
    end
  end
end
