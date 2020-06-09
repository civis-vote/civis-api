class CreateConsultationHindiSummaries < ActiveRecord::Migration[6.0]
  def change
    create_table :consultation_hindi_summaries do |t|
    	t.references :consultation, null: true, foreign_key: true
      t.timestamps
    end
  end
end
