class CreateUserNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :user_notifications do |t|
      t.integer :user_id
      t.string :notification_type
      t.boolean :notification_status
      t.integer :consultation_id
      t.string :consultation_title
      t.timestamps
    end
    add_index :user_notifications, [:user_id, :notification_type, :consultation_id], unique: true, name: :user_id_notification_type_and_consultation_id_index
  end
end
