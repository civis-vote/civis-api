class AddHindiAndOdiyaToQuestions < ActiveRecord::Migration[6.0]
  def up
    add_column :questions, :question_text_hindi, :string
    add_column :questions, :question_text_odia, :string
  end

  def down
    remove_column :questions, :question_text_hindi
    remove_column :questions, :question_text_odia
  end
end