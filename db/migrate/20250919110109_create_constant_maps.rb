class CreateConstantMaps < ActiveRecord::Migration[7.1]
  def change
    create_table :constant_maps do |t|
      t.references :constant, null: false, foreign_key: true
      t.references :mappable, polymorphic: true

      t.timestamps
    end
  end
end
