class RenameIsApprovedToResponseStatusInConsultationResponse < ActiveRecord::Migration[6.0]
  def change
    rename_column :consultation_responses, :is_approved, :response_status
  end
end