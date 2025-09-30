class AddLimitToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :answer_limit, :integer
  end
end
