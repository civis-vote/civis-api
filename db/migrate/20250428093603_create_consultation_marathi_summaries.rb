class CreateConsultationMarathiSummaries < ActiveRecord::Migration[7.1]
  def change
    create_table :consultation_marathi_summaries do |t|
      t.references :consultation, null: true, foreign_key: true

      t.timestamps
    end
  end
end
