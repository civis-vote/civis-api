class AddVisibilityToConsultationResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :consultation_responses, :visibility, :integer, default: 1
    remove_column :consultation_responses, :is_anonymous, :boolean
  end
end