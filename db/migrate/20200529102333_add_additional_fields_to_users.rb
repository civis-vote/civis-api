class AddAdditionalFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :organization, :string
    add_column :users, :callback_url, :string
    add_column :users, :designation, :string
  end
end
