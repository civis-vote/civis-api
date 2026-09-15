class AddStatusToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :status, :integer, default: 0, null: false unless column_exists?(:users, :status)

    # Backfill from the legacy boolean column so previously deactivated users stay disabled
    execute <<~SQL
      UPDATE users SET status = CASE WHEN active THEN 0 ELSE 1 END
    SQL
  end

  def down
    remove_column :users, :status, if_exists: true
  end
end
