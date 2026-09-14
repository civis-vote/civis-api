class CreateCmPrompts < ActiveRecord::Migration[8.1]
  def change
    create_table :cm_prompts do |t|
      t.string :name, null: false
      t.citext :slug, null: false
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :cm_prompts, :name, unique: true
    add_index :cm_prompts, :slug, unique: true
  end
end
