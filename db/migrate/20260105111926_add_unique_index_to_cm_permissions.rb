class AddUniqueIndexToCmPermissions < ActiveRecord::Migration[7.0]
  def change
    add_index :cm_permissions,
              [:ar_model_name, :action_name, :cm_role_id],
              unique: true,
              name: :index_cm_permissions_on_model_action_role
  end
end