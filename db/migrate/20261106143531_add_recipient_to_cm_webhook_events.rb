class AddRecipientToCmWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :cm_webhook_events, :recipient_type, :string unless column_exists?(:cm_webhook_events, :recipient_type)
    add_column :cm_webhook_events, :recipient_id, :bigint unless column_exists?(:cm_webhook_events, :recipient_id)
    add_index :cm_webhook_events, %i[recipient_type recipient_id] unless index_exists?(:cm_webhook_events, %i[recipient_type recipient_id])
    return if column_exists?(:cm_webhook_events, :original_link)

    add_column :cm_webhook_events, :original_link, :string
  end
end
