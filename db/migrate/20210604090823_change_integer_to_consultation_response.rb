class ChangeIntegerToConsultationResponse < ActiveRecord::Migration[6.0]
  def change
  	ConsultationResponse.reset_column_information
  	change_column :consultation_responses, :import_key, :string
  end
end