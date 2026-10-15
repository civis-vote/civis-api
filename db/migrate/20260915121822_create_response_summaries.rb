class CreateResponseSummaries < ActiveRecord::Migration[8.1]
  def up
    create_table :response_summaries do |t|
      t.references :consultation, null: false, foreign_key: true
      t.integer :total_responses, null: false, default: 0

      t.timestamps
    end

    create_table :response_question_summaries do |t|
      t.references :response_summary, null: false, foreign_key: true
      t.integer :question_id, null: false
      t.string :question_text, null: false
      t.string :question_type, null: false
      t.boolean :is_optional, null: false, default: false
      t.integer :position
      t.integer :total_responses, null: false, default: 0
      t.integer :text_response_count
      t.integer :voice_response_count
      t.integer :other_option_count

      t.timestamps
    end

    create_table :response_option_breakdowns do |t|
      t.references :response_question_summary, null: false, foreign_key: true
      t.integer :option_id, null: false
      t.string :option_text, null: false
      t.integer :selection_count, null: false, default: 0
      t.float :percentage, null: false, default: 0.0

      t.timestamps
    end
  end

  def down
    drop_table :response_option_breakdowns, if_exists: true
    drop_table :response_question_summaries, if_exists: true
    drop_table :response_summaries, if_exists: true
  end
end
