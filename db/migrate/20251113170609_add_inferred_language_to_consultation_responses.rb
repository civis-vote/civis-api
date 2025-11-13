class AddInferredLanguageToConsultationResponses < ActiveRecord::Migration[7.1]
  def change
    add_column :consultation_responses, :inferred_language, :string
  end
end
