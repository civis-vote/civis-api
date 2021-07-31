class AddUniqueIndexUserCounts < ActiveRecord::Migration[6.0]
  def change
    add_index :user_counts, :user_id, unique: true
  end
end