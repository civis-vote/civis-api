class AddIsConditionalToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :is_conditional, :boolean, default: false
    add_column :questions, :conditional_question_id, :bigint
    add_column :questions, :conditional_question_option_id, :bigint
    add_column :questions, :show_conditional_question_on_answer, :boolean, default: false
  end
end
