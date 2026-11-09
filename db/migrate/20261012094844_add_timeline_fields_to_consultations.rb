class AddTimelineFieldsToConsultations < ActiveRecord::Migration[8.1]
  def change
    add_column :consultations, :feedback_submitted_at, :datetime
    add_column :consultations, :acknowledged_at, :datetime
    add_column :consultations, :policy_released_at, :datetime
  end
end
