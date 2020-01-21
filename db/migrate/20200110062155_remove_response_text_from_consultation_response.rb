class RemoveResponseTextFromConsultationResponse < ActiveRecord::Migration[6.0]
  def change
    remove_column :consultation_responses, :response_text, :text
    remove_column :consultations, :summary, :text
  end
end
