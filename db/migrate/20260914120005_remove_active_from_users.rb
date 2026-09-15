class RemoveActiveFromUsers < ActiveRecord::Migration[8.1]
  def up
    remove_column :users, :active if column_exists?(:users, :active)
  end

  def down
    add_column :users, :active, :boolean, default: true unless column_exists?(:users, :active)
  end
end
