class CreateUserProfanityCounts < ActiveRecord::Migration[6.0]
  def change
    create_table :user_profanity_counts,primary_key:[:user_id] do |t|
      t.bigint :user_id
      t.bigint :profanity_count

      t.timestamps
    end
    add_index :user_profanity_counts, :user_id
  end
end

