class ChangeColumnTypeForWordindices < ActiveRecord::Migration[6.0]
  def up
    change_column :wordindices, :description, :string
  end

  def down
    change_column :wordindices, :description, :text
  end
end
