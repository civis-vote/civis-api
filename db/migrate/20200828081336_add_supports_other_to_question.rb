class AddSupportsOtherToQuestion < ActiveRecord::Migration[6.0]
  def change
  	Question.reset_column_information
    add_column :questions, :supports_other, :boolean, default: false
  end
end
