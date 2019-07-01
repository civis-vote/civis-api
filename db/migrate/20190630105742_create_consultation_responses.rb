class CreateConsultationResponses < ActiveRecord::Migration[6.0]
  def change
    create_table :consultation_responses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :consultation, null: false, foreign_key: true
      t.integer :satisfaction_rating
      t.text :response_text
      t.boolean :is_anonymous

      t.timestamps
    end
  end
end
