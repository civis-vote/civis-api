class RemoveIndexUserCounts < ActiveRecord::Migration[6.0]
  def change
    remove_index :user_counts, name: "index_user_counts_on_user_id"
  end
end