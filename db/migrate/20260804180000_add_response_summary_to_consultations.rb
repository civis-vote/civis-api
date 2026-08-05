class AddResponseSummaryToConsultations < ActiveRecord::Migration[8.1]
  def change
    add_column :consultations, :response_summary, :jsonb, default: {}
  end
end
