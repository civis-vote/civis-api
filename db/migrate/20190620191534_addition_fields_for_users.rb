class AdditionFieldsForUsers < ActiveRecord::Migration[6.0]
  def change
  	add_column :users, :first_name, :string
  	add_column :users, :last_name, :string
  	add_column :users, :city_id, :integer
  end
end