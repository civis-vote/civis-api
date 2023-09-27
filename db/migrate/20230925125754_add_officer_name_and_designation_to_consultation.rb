class AddOfficerNameAndDesignationToConsultation < ActiveRecord::Migration[6.0]
  def change
    add_column :consultations, :officer_name, :string
    add_column :consultations, :officer_designation, :string
  end
end
