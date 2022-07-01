class CreateNotificationTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :notification_types do |t|
      t.string :notification_type
      t.string :notification_main_text
      t.string :notification_sub_text
      t.timestamps
    end
    add_index :notification_types, :notification_type, unique: true
  end
end
