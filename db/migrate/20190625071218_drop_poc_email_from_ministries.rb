class DropPocEmailFromMinistries < ActiveRecord::Migration[6.0]
  def change
  	remove_column :ministries, :poc_email
  end
end
