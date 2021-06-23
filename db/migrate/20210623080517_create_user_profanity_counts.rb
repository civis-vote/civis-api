class CreateUserProfanityCounts < ActiveRecord::Migration[6.0]
  def change
    create_table :user_profanity_counts do |t|
      t.integer :user_id
      t.integer :profanity_count

      t.timestamps
    end
    add_index :user_profanity_counts, :user_id
  end
end
