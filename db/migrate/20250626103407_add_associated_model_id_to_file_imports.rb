class AddAssociatedModelIdToFileImports < ActiveRecord::Migration[7.1]
  def change
    add_column :file_imports, :associated_model_id, :bigint
  end
end
