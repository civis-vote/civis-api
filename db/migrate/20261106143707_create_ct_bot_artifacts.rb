class CreateCtBotArtifacts < ActiveRecord::Migration[8.1]
  def change
    create_table :ct_bot_artifacts do |t|
      t.references :ct_bot_message, null: false, foreign_key: true
      t.integer :kind, null: false
      t.jsonb :payload, null: false, default: {}
      t.jsonb :response
      t.datetime :closed_at
      t.string :tool_call_id

      t.timestamps
    end
  end
end
