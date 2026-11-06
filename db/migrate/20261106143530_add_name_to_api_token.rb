class AddNameToApiToken < ActiveRecord::Migration[8.1]
  def up
    add_column :api_tokens, :name, :string unless column_exists?(:api_tokens, :name)
    execute "UPDATE api_tokens SET name = 'Unnamed Token' WHERE name IS NULL"
    remove_column :api_tokens, :description if column_exists?(:api_tokens, :description)
  end

  def down
    add_column :api_tokens, :description, :text unless column_exists?(:api_tokens, :description)
    remove_column :api_tokens, :name if column_exists?(:api_tokens, :name)
  end
end
