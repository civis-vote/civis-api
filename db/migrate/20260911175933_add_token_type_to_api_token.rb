class AddTokenTypeToApiToken < ActiveRecord::Migration[8.1]
  def change
    add_column :api_tokens, :token_type, :integer, default: 0, null: false unless column_exists?(:api_tokens, :token_type)
    add_column :api_tokens, :expires_at, :datetime unless column_exists?(:api_tokens, :expires_at)
  end
end
