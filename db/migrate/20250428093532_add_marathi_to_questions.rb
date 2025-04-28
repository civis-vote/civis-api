class AddMarathiToQuestions < ActiveRecord::Migration[7.1]
  def up
    add_column :questions, :question_text_marathi, :text
  end

  def down
    remove_column :questions, :question_text_marathi, :text
  end
end
