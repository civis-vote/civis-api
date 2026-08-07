class CreateClauseFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :clause_feedbacks do |t|
      t.references :clause, null: false, foreign_key: true
      t.references :consultation_response, null: false, foreign_key: true

      t.timestamps
    end
  end
end
