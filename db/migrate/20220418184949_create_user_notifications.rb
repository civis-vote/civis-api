class CreateUserNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :user_notifications do |t|
      t.bigint :user_id
      t.text :notificationDetails
      t.boolean :status

      t.timestamps
    end
  end
end
