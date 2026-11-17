class ChangeUsersEmailToCitext < ActiveRecord::Migration[8.1]
  def up
    enable_extension "citext" unless extension_enabled?("citext")
    change_column :users, :email, :citext
  end

  def down
    change_column :users, :email, :string
  end
end
