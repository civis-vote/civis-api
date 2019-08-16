class AddPointsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :points, :float, default: 0.0
  end
end
