class AddOrganisationIdToConsultation < ActiveRecord::Migration[6.0]
  def change
    add_column :consultations, :organisation_id, :integer
    add_column :consultations, :private_response, :integer, default: false
  end
end
