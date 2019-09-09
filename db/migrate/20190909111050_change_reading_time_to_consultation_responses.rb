class ChangeReadingTimeToConsultationResponses < ActiveRecord::Migration[6.0]
  def change
  	change_column :consultation_responses, :reading_time, :integer, default: 0
  end
end
