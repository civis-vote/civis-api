class AddPocFieldsToMinistries < ActiveRecord::Migration[6.0]
  def change
    add_column :ministries, :poc_email_primary, :string
    add_column :ministries, :poc_email_secondary, :string
  end
end
