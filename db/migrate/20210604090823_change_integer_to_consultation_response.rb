class ChangeIntegerToConsultationResponse < ActiveRecord::Migration[6.0]
  def change
  	change_column :consultation_responses, :import_key, :string
  end
end