class CreateQuestions < ActiveRecord::Migration[6.0]
  def self.up
    create_table :questions do |t|
      t.integer :parent_id
      t.string :question_text
      t.integer :question_type
      t.references :consultation, null: true, foreign_key: true
      t.timestamps
    end
    add_column :consultation_responses, :answers, :jsonb
  end
  def self.down
    remove_column :consultation_responses, :answers
  end
end
