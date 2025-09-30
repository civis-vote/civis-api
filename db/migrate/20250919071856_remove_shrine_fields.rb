class RemoveShrineFields < ActiveRecord::Migration[7.1]
  def change
    remove_column :themes, :cover_photo_data
    remove_column :themes, :cover_photo_versions_data
    remove_column :departments, :logo_data
    remove_column :departments, :logo_versions_data
    remove_column :organisations, :logo_data
    remove_column :organisations, :logo_versions_data
    remove_column :users, :profile_picture_data
    remove_column :users, :profile_picture_versions_data
  end
end
