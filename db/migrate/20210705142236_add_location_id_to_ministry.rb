class AddLocationIdToMinistry < ActiveRecord::Migration[6.0]
  def change
  	add_column :ministries, :location_id, :integer, default: 0
  end
end
