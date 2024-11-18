class AddFeedbackEmailDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :consultations, :feedback_email_message_id, :string
    add_column :consultations, :feedback_email_delivered_at, :datetime
    add_column :consultations, :feedback_email_opened_at, :datetime
    add_index :consultations, :feedback_email_message_id
  end
end
