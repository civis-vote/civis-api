class CreateConstants < ActiveRecord::Migration[6.0]
  def change
    create_table :constants do |t|
      t.string :name
      t.integer :constant_type

      t.timestamps
    end
  end
end
