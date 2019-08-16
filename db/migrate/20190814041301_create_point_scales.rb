class CreatePointScales < ActiveRecord::Migration[6.0]
  def change
    create_table :point_scales do |t|
      t.integer :upper_limit
      t.integer :action

      t.timestamps
    end
  end
end
