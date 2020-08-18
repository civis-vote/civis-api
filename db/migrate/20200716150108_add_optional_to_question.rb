class AddOptionalToQuestion < ActiveRecord::Migration[6.0]
  def change
  	remove_column :questions, :optional, :boolean, default: false
    add_column :questions, :is_optional, :boolean, default: false
    Question.reset_column_information
  end
end
