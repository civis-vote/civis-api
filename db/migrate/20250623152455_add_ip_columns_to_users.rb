class AddIpColumnsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :current_ip, :string
    add_column :users, :sign_up_ip, :string
    add_column :users, :last_active_at, :datetime
  end
end
