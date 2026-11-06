class CreateCtBotMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :ct_bot_messages do |t|
      t.references :ct_bot_conversation, null: false, foreign_key: true
      t.integer :role, null: false
      t.integer :status, null: false, default: 0
      t.boolean :read, null: false, default: true
      t.decimal :total_cost_cents, precision: 20, scale: 8, null: false, default: 0
      t.datetime :completed_at

      t.timestamps
    end

    add_index :ct_bot_messages, :created_at, order: { created_at: :desc }
  end
end
