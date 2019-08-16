class AddTemplatesCountToConsultationResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :consultation_responses, :templates_count, :integer, default: 0
  end
end
