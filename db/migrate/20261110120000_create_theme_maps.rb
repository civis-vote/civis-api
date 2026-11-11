class CreateThemeMaps < ActiveRecord::Migration[8.1]
  def change
    create_table :theme_maps do |t|
      t.bigint :theme_id, null: false
      t.string :mappable_type
      t.bigint :mappable_id
      t.timestamps
    end

    add_index :theme_maps, %i[theme_id mappable_type mappable_id], unique: true,
              name: "index_theme_maps_on_theme_and_mappable"
    add_index :theme_maps, %i[mappable_type mappable_id], name: "index_theme_maps_on_mappable"
    add_foreign_key :theme_maps, :themes
  end
end
