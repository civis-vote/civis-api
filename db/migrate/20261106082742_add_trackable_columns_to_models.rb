class AddTrackableColumnsToModels < ActiveRecord::Migration[8.1]
  def change
    add_reference :cm_roles, :created_by, foreign_key: { to_table: :users }
    add_reference :cm_roles, :updated_by, foreign_key: { to_table: :users }
  end
end
