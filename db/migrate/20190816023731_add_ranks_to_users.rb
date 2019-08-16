class AddRanksToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :rank, :integer, default: 0
    add_column :users, :state_rank, :integer, default: 0
    add_column :users, :city_rank, :integer, default: 0
  end
end
