class CreateCtBotTranscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :ct_bot_transcriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :ct_bot_conversation, foreign_key: true
      t.references :ct_bot_message, foreign_key: true
      t.string :request_id
      t.integer :status, null: false, default: 0
      t.text :text
      t.string :error_message
      t.decimal :total_cost_cents, precision: 20, scale: 8, null: false, default: 0
      t.datetime :completed_at

      t.timestamps
    end
  end
end
