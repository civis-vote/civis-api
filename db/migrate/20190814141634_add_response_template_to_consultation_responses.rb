class AddResponseTemplateToConsultationResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :consultation_responses, :template_id, :integer
  end
end
