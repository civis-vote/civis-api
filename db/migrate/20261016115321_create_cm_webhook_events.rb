class CreateCmWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :cm_webhook_events do |t|
      t.integer :cm_service
      t.integer :host_service
      t.string :event_type, null: false
      t.integer :status, null: false, default: 0
      t.string :event_id
      t.string :uuid, null: false
      t.text :error_message
      t.datetime :processed_at
      t.references :eventable, polymorphic: true, null: true

      t.timestamps
    end

    add_index :cm_webhook_events, :status
    add_index :cm_webhook_events, :cm_service
    add_index :cm_webhook_events, :host_service
    add_index :cm_webhook_events, :event_type
    add_index :cm_webhook_events, :event_id
    add_index :cm_webhook_events, :uuid, unique: true
    add_index :cm_webhook_events, :created_at
    add_index :cm_webhook_events, %i[cm_service event_id event_type]
    add_index :cm_webhook_events, %i[host_service event_id event_type]
  end
end
