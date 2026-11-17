class RemoveStatusFromApiToken < ActiveRecord::Migration[8.1]
  def up
    return unless column_exists?(:api_tokens, :status)

    # Tokens marked expired (status = 1) that would otherwise still be valid by
    # date are stamped as expired now, so dropping the column revives none of them.
    execute <<~SQL
      UPDATE api_tokens SET expires_at = CURRENT_TIMESTAMP
      WHERE status = 1 AND (expires_at IS NULL OR expires_at > CURRENT_TIMESTAMP)
    SQL
    remove_column :api_tokens, :status
  end

  def down
    return if column_exists?(:api_tokens, :status)

    add_column :api_tokens, :status, :integer, default: 0
    execute "UPDATE api_tokens SET status = 1 WHERE expires_at <= CURRENT_TIMESTAMP"
  end
end
