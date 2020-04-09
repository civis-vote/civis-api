class AddLogoVersionsDataToMinistry < ActiveRecord::Migration[6.0]
  def self.up
    add_column :ministries, :logo_versions_data, :jsonb
    add_column :categories, :cover_photo_versions_data, :jsonb
    add_column :users, :profile_picture_versions_data, :jsonb
  end
  def self.down
  	
  end
end
