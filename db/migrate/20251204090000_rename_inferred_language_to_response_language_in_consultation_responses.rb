class RenameInferredLanguageToResponseLanguageInConsultationResponses < ActiveRecord::Migration[7.1]
  def change
    rename_column :consultation_responses, :inferred_language, :response_language
  end
end
