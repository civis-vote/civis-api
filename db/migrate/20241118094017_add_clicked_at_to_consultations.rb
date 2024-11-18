class AddClickedAtToConsultations < ActiveRecord::Migration[7.1]
  def change
    add_column :consultations, :feedback_email_clicked_at, :datetime
  end
end
