class AddDefaultToRoles < ActiveRecord::Migration[6.0]
  def change
  	change_column_default :users, :role, from: nil, to: 0
  end
end
