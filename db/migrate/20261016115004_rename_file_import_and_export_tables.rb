class RenameFileImportAndExportTables < ActiveRecord::Migration[8.1]
  MODEL_RENAMES = {
    'FileImport' => 'CtFileImport',
    'FileExport' => 'CtFileExport'
  }.freeze

  MODEL_REFERENCE_COLUMNS = {
    active_storage_attachments: :record_type,
    versions: :item_type,
    cm_permissions: :ar_model_name,
    cm_index_preferences: :ar_model_name
  }.freeze

  def up
    rename_table :file_imports, :ct_file_imports if table_exists?(:file_imports) && !table_exists?(:ct_file_imports)
    rename_table :file_exports, :ct_file_exports if table_exists?(:file_exports) && !table_exists?(:ct_file_exports)
    rename_model_references(MODEL_RENAMES)
  end

  def down
    rename_model_references(MODEL_RENAMES.invert)
    rename_table :ct_file_imports, :file_imports if table_exists?(:ct_file_imports) && !table_exists?(:file_imports)
    rename_table :ct_file_exports, :file_exports if table_exists?(:ct_file_exports) && !table_exists?(:file_exports)
  end

  private

  def rename_model_references(renames)
    MODEL_REFERENCE_COLUMNS.each do |table_name, column_name|
      next unless table_exists?(table_name) && column_exists?(table_name, column_name)

      renames.each do |old_name, new_name|
        execute <<~SQL.squish
          UPDATE #{connection.quote_table_name(table_name)}
          SET #{connection.quote_column_name(column_name)} = #{connection.quote(new_name)}
          WHERE #{connection.quote_column_name(column_name)} = #{connection.quote(old_name)}
        SQL
      end
    end
  end
end
