class AddRubyLlmPersistenceToCtBot < ActiveRecord::Migration[8.1]
  DEFAULT_BOT_PROVIDER = "openrouter".freeze

  def up
    change_table :ct_bot_conversations, bulk: true do |t|
      t.references :ruby_llm_model, foreign_key: {to_table: :ruby_llm_models}
      t.boolean :cancelled, null: false, default: false
      t.string :claim_token
      t.datetime :claimed_until
    end
    add_index :ct_bot_conversations, :claimed_until, where: "claim_token IS NOT NULL"

    change_column :ct_bot_messages, :role, :string,
      using: "CASE role WHEN 0 THEN 'user' WHEN 1 THEN 'assistant' ELSE 'assistant' END"

    change_table :ct_bot_messages, bulk: true do |t|
      t.boolean :cache_until_here, null: false, default: false
      t.string :cache_ttl
      t.text :thinking_text
      t.text :thinking_signature
      t.jsonb :citations
      t.jsonb :server_tool_calls
      t.jsonb :raw_content
      t.jsonb :raw_reasoning
      t.string :phase
      t.text :continuation
      t.string :finish_reason
    end

    drop_table :ct_cost_trackings, if_exists: true

    backfill_conversation_models
    rename_message_attachments
  end

  def down
    create_table :ct_cost_trackings, if_not_exists: true do |t|
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

    execute "UPDATE active_storage_attachments SET name = 'files' " \
            "WHERE record_type = 'CtBotMessage' AND name = 'attachments'"

    change_table :ct_bot_messages, bulk: true do |t|
      t.remove :cache_until_here, :cache_ttl, :thinking_text, :thinking_signature,
        :citations, :server_tool_calls, :raw_content, :raw_reasoning, :phase, :continuation, :finish_reason
    end
    change_column :ct_bot_messages, :role, :integer, using: "CASE role WHEN 'user' THEN 0 ELSE 1 END"

    remove_index :ct_bot_conversations, :claimed_until
    change_table :ct_bot_conversations, bulk: true do |t|
      t.remove :ruby_llm_model_id, :cancelled, :claim_token, :claimed_until
    end
  end

  private

  def backfill_conversation_models
    if defined?(RubyLLM) && RubyLLM.respond_to?(:models) && RubyLLM.models.respond_to?(:refresh)
      begin
        RubyLLM.models.refresh
      rescue StandardError => e
        warn "RubyLLM model catalog refresh failed (#{e.class}: #{e.message}); continuing with existing catalog"
      end
    end
    bot_model = CmAdmin::PlatformSettings.fetch("ct-bot-model", "openai/gpt-5.6-sol")
    execute "UPDATE ct_bot_conversations SET ruby_llm_model_id = " \
            "(SELECT id FROM ruby_llm_models WHERE provider = #{quoted(DEFAULT_BOT_PROVIDER)} " \
            "AND model_id = #{quoted(bot_model)}) WHERE ruby_llm_model_id IS NULL"
  end

  def rename_message_attachments
    execute "UPDATE active_storage_attachments SET name = 'attachments' " \
            "WHERE record_type = 'CtBotMessage' AND name = 'files'"
  end

  def quoted(value)
    ActiveRecord::Base.connection.quote(value)
  end
end
