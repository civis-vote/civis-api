class CreateNotificationSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :notification_settings do |t|
      t.boolean :on_new_consultation
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
