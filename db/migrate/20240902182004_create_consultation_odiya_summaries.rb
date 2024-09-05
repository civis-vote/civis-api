class CreateConsultationOdiyaSummaries < ActiveRecord::Migration[6.0]
  def up
    create_table :consultation_odia_summaries do |t|
      t.references :consultation, null: true, foreign_key: true
      t.timestamps
    end
  end

  def down
    drop_table :consultation_odia_summaries
  end
end