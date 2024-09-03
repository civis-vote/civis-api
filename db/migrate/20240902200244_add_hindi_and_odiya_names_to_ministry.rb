class AddHindiAndOdiyaNamesToMinistry < ActiveRecord::Migration[7.1]
  def up
    add_column :ministries, :name_hindi, :string
    add_column :ministries, :name_odia, :string
  end

  def down
    remove_column :ministries, :name_hindi
    remove_column :ministries, :name_odia
  end
end