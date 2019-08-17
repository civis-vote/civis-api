class RemoveRankDefaultsFromUsers < ActiveRecord::Migration[6.0]
  def change
  	change_column_default :users, :rank, from: 0, to: nil
  	change_column_default :users, :city_rank, from: 0, to: nil
  	change_column_default :users, :state_rank, from: 0, to: nil
  end
end