class RemoveConditionalQuestionOptionFields < ActiveRecord::Migration[7.1]
  def change
    remove_column :questions, :conditional_question_option_id, :bigint
    remove_column :questions, :is_conditional, :boolean
    remove_column :questions, :show_conditional_question_on_answer, :boolean
    remove_column :questions, :conditional_question_id, :bigint

    add_reference :questions, :conditional_question, foreign_key: { to_table: :questions }
  end
end
