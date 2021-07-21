class CreateProfanities < ActiveRecord::Migration[6.0]
  def change
    create_table :profanities do |t|
      t.string :profane_word
      t.integer :created_by_id
      t.timestamps
    end
    add_index :profanities, :profane_word, unique: true
  end
end