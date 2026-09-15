class AddAuditMetadataToVersions < ActiveRecord::Migration[8.1]
  def change
    add_column :versions, :action_type, :string
    add_index :versions, :action_type
    add_column :versions, :action_name, :string
    add_index :versions, :action_name
  end
end
