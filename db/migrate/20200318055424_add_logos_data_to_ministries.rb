class AddLogosDataToMinistries < ActiveRecord::Migration[6.0]
  def change
    add_column :ministries, :logo_data, :text
    add_column :categories, :cover_photo_data, :text
    add_column :users, :profile_picture_data, :text
  end
end