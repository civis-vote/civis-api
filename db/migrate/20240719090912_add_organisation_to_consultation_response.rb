class AddOrganisationToConsultationResponse < ActiveRecord::Migration[7.1]
  def change
    add_reference :consultation_responses, :organisation, foreign_key: true
  end
end
