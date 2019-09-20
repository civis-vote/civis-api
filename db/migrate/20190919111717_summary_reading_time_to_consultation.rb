class SummaryReadingTimeToConsultation < ActiveRecord::Migration[6.0]
  def change
  	add_column :consultations, :reading_time, :integer, default: 0
  end
end
