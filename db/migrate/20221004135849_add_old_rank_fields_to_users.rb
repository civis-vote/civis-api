class AddOldRankFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :old_city_rank, :integer
    add_column :users, :old_state_rank, :integer
    add_column :users, :old_rank, :integer
  end
end
