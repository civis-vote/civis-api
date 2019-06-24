class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.integer :parent_id
      t.integer :location_type

      t.timestamps
    end
  end
end
