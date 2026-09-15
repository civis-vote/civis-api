class ImproveFileImport < ActiveRecord::Migration[8.1]
  def change
    add_column :file_imports, :associated_model_id, :bigint unless column_exists?(:file_imports, :associated_model_id)
    add_column :file_imports, :action_name, :string unless column_exists?(:file_imports, :action_name)
    add_column :file_imports, :importer_class_name, :string unless column_exists?(:file_imports, :importer_class_name)
    add_column :file_imports, :import_type, :integer unless column_exists?(:file_imports, :import_type)
  end
end
