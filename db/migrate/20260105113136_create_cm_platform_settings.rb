class CreateCmPlatformSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_platform_settings do |t|
      t.string :name, null: false, unique: true
      t.string :slug, null: false, index: true, unique: true
      t.references :category, foreign_key: { to_table: :constants }
      t.text :description
      t.text :value
      t.references :created_by, polymorphic: true
      t.references :updated_by, polymorphic: true

      t.timestamps
    end
  end
end
