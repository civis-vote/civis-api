class AddHMarathiNamesToMinistry < ActiveRecord::Migration[7.1]
  def change
    add_column :ministries, :name_marathi, :string
  end
end
