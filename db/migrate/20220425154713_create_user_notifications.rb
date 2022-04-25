class CreateUserNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :user_notifications do |t|
      t.integer :user_id
      t.text :notification_details
      t.string :type
      t.integer :old_rank
      t.boolean :status

      t.timestamps
    end
  end
end
