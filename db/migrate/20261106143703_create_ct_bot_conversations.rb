class CreateCtBotConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :ct_bot_conversations do |t|
      t.string :title
      t.references :user, null: false, foreign_key: true
      t.decimal :total_cost_cents, precision: 20, scale: 8, null: false, default: 0

      t.timestamps
    end

    add_index :ct_bot_conversations, :created_at, order: { created_at: :desc }
    add_index :ct_bot_conversations, :updated_at, order: { updated_at: :desc }
  end
end
