class AddRefererIdToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :referer_id, :integer
  end
end
