class AddMetaIsApprovedToConsultationResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :consultation_responses, :is_approved, :integer, default: 0
    add_column :consultation_responses, :meta, :jsonb
  end
end
