class CreateUserNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :user_notifications do |t|
      t.integer :user_id
      t.string :notification_type
      t.integer :consultation_id
      t.integer :old_rank
      t.boolean :notification_status
      t.timestamps
    end
    add_index :user_notifications, [:user_id, :notification_type, :consultation_id], unique: true, name: :user_id_notification_type_and_consultation_id_index
  end
end
