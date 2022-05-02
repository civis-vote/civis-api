class CreateUserCounts < ActiveRecord::Migration[6.0]
  def change
    create_table :user_counts do |t|
      t.integer :user_id
      t.integer :profanity_count
      t.integer :short_response_count

      t.timestamps
    end
    add_index :user_counts, :user_id
  end
end
