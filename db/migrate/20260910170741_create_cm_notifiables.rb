class CreateCmNotifiables < ActiveRecord::Migration[8.1]
  def change
    create_table :cm_notifiables do |t|
      t.references :notifiable, polymorphic: true, null: false
      t.integer :notification_type, null: false, default: 0
      t.string :value, null: false
      t.timestamps
    end

    add_index :cm_notifiables, :notification_type
  end
end
