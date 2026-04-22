class AddKannadaToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :question_text_kannada, :text
  end
end
