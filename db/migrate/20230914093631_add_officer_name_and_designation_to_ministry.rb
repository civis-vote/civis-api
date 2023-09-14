class AddOfficerNameAndDesignationToMinistry < ActiveRecord::Migration[6.0]
  def change
    add_column :ministries, :primary_officer_name, :string
    add_column :ministries, :primary_officer_designation, :string
    add_column :ministries, :secondary_officer_name, :string
    add_column :ministries, :secondary_officer_designation, :string
  end
end
