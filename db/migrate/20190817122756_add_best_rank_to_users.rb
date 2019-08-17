class AddBestRankToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :best_rank, :integer
    add_column :users, :best_rank_type, :integer
  end
end
