class AddCreatedByIdToMinistries < ActiveRecord::Migration[6.0]
  def change
    add_column :ministries, :created_by_id, :integer
  end
end
