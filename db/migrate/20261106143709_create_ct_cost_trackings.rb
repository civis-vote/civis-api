class CreateCtCostTrackings < ActiveRecord::Migration[8.1]
  def change
    create_table :ct_cost_trackings do |t|
      t.references :trackable, polymorphic: true, null: false
      t.string :provider
      t.string :model
      t.bigint :input_tokens
      t.bigint :output_tokens
      t.bigint :cache_read_tokens
      t.bigint :thinking_tokens
      t.decimal :total_cost_cents, precision: 20, scale: 8
      t.jsonb :details, default: {}

      t.timestamps
    end
  end
end
