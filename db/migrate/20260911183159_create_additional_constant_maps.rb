class CreateAdditionalConstantMaps < ActiveRecord::Migration[8.1]
  def change
    return if table_exists?(:constant_maps)

    create_table :constant_maps do |t|
      t.references :constant, null: false
      t.references :mappable, polymorphic: true, null: false
      t.timestamps
    end

    add_index :constant_maps, %i[constant_id mappable_id mappable_type], unique: true
  end
end
