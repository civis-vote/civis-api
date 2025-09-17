class ImproveFileExport < ActiveRecord::Migration[7.0]
  def change
    add_column :file_exports, :export_type, :integer, default: 0 unless column_exists?(:file_exports, :export_type)
    add_column :file_exports, :completed_at, :datetime unless column_exists?(:file_exports, :completed_at)
    add_column :file_exports, :associated_model_id, :bigint unless column_exists?(:file_exports, :associated_model_id)
    add_column :file_exports, :action_name, :string unless column_exists?(:file_exports, :action_name)
    add_column :file_exports, :url, :string unless column_exists?(:file_exports, :url)
    add_column :file_exports, :error_report, :jsonb, default: {} unless column_exists?(:file_exports, :error_report)
  end
end
