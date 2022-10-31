class AddWelcomeNotificationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :welcome_notification, :boolean, default: false
  end
end
