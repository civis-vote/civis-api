class AddParentIdToConstants < ActiveRecord::Migration[6.0]
  def change
    add_column :constants, :parent_id, :integer
  end
end
