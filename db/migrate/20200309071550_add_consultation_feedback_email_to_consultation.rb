class AddConsultationFeedbackEmailToConsultation < ActiveRecord::Migration[6.0]
  def change
    add_column :consultations, :consultation_feedback_email, :string
  end
end
