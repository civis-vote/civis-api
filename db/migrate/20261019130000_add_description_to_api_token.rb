class AddDescriptionToApiToken < ActiveRecord::Migration[8.1]
  def change
    add_column :api_tokens, :description, :text
  end
end
