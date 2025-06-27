class CreateFileExports < ActiveRecord::Migration[7.1]
  def change
    create_table :file_exports do |t|
      t.string :associated_model_name
      t.references :exported_by, polymorphic: true, null: false
      t.datetime :expires_at
      t.integer :status, default: 0
      t.jsonb :params, default: {}

      t.timestamps
    end
  end
end
