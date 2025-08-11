class CreateCmPermission < ActiveRecord::Migration[7.1]
  def change
    create_table :cm_permissions do |t|
      t.string :action_name
      t.string :action_display_name
      t.string :ar_model_name
      t.string :scope_name
      t.references :cm_role, null: false, foreign_key: true

      t.timestamps
    end
  end
end
