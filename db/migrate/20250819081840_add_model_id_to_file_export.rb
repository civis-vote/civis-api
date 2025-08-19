class AddModelIdToFileExport < ActiveRecord::Migration[7.1]
  def change
    add_column :file_exports, :associated_model_id, :integer
    add_column :file_exports, :action_name, :string
    add_column :file_exports, :url, :string
    add_column :file_exports, :export_type, :integer, default: 0
    add_column :file_exports, :completed_at, :datetime
  end
end
