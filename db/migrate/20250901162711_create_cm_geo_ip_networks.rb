class CreateCmGeoIpNetworks < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'btree_gist' unless extension_enabled?('btree_gist')

    create_table :cm_geo_ip_networks do |t|
      t.cidr :network, null: false
      t.references :cm_geo_ip_location, foreign_key: true
      t.integer :registered_country_geoname_id
      t.integer :represented_country_geoname_id
      t.boolean :is_anonymous_proxy
      t.boolean :is_satellite_provider
      t.boolean :is_anycast

      t.index :network, using: :gist
    end
  end
end
