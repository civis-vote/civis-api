class CreateCmIndexPreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :cm_index_preferences do |t|
      t.integer :user_id, null: false, index: true
      t.string :ar_model_name, null: false, index: true
      t.string :associated_ar_model_name, index: true
      t.string :visible_columns, array: true, default: []
      t.string :hidden_columns, array: true, default: []
      t.integer :records_per_page, default: 20

      t.timestamps
    end
  end
end
