class CreatePointEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :point_events do |t|
      t.references :point_scale, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.float :points

      t.timestamps
    end
  end
end