class AddPointsToPointScales < ActiveRecord::Migration[6.0]
  def change
    add_column :point_scales, :points, :float
  end
end
