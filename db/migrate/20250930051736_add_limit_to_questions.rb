class AddLimitToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :selected_options_limit, :integer
  end
end
