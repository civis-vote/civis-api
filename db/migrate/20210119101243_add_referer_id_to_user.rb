class AddRefererIdToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :referring_consultation_id, :integer
  end
end
