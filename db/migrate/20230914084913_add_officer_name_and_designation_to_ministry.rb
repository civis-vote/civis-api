class AddOfficerNameAndDesignationToMinistry < ActiveRecord::Migration[6.0]
  def change
    add_column :ministries, :officer_name, :string
    add_column :ministries, :officer_designation, :string
  end
end
