class AddReadingTimeToConsultationResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :consultation_responses, :reading_time, :integer
  end
end
