class CreateCmEmailLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :cm_email_logs do |t|
      t.string :message_id
      t.string :subject
      t.text :to
      t.text :cc
      t.text :bcc
      t.string :reply_to
      t.string :from_email
      t.string :from_name
      t.integer :status, null: false, default: 0
      t.string :template_name
      t.string :partial_file_path
      t.string :in_reply_to
      t.string :references
      t.jsonb :delivery_method_options
      t.jsonb :attachment_metadata
      t.string :module_name
      t.references :record, polymorphic: true, null: true
      t.string :record_url
      t.references :triggered_by, null: true, foreign_key: { to_table: :users }
      t.string :triggered_by_type, null: true
      t.text :failure_reason
      t.string :error_code
      t.text :raw_error_response
      t.datetime :failed_at
      t.datetime :sent_at

      t.timestamps
    end

    add_index :cm_email_logs, :status
    add_index :cm_email_logs, :created_at
    add_index :cm_email_logs, :module_name
    add_index :cm_email_logs, :message_id
  end
end
