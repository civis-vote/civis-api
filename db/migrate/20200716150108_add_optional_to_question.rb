class AddOptionalToQuestion < ActiveRecord::Migration[6.0]
  def change
    add_column :questions, :is_optional, :boolean, default: false
    Question.reset_column_information
  end
end