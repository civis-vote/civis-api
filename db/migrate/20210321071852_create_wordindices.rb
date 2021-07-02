class CreateWordindices < ActiveRecord::Migration[6.0]
  def change
    create_table :wordindices do |t|
      t.string :word
      t.text :description
      t.integer :created_by_id
      t.timestamps
    end
    add_index :wordindices, :word
  end
end
