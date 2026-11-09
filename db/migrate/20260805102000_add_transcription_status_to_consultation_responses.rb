class AddTranscriptionStatusToConsultationResponses < ActiveRecord::Migration[8.1]
  def change
    add_column :consultation_responses, :transcription_status, :integer, default: 0, null: false
    add_column :consultation_responses, :transcription_errors, :jsonb, default: [], null: false
  end
end
