class AddIsConditionalToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :is_conditional, :boolean, default: false
    add_column :questions, :conditional_question_id, :bigint
  end
end
