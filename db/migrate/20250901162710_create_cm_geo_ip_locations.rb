class CreateCmGeoIpLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_geo_ip_locations do |t|
      t.string :locale_code, null: false
      t.string :continent_code
      t.string :continent_name
      t.string :country_iso_code
      t.string :country_name
      t.boolean :is_in_european_union

      t.index :locale_code
      t.index :country_iso_code
    end
  end
end
