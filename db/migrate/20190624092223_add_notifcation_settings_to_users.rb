class AddNotifcationSettingsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :notification_settings, :jsonb
  end
end
