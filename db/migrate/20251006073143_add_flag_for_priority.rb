class AddFlagForPriority < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :has_choice_priority, :boolean, default: false
  end
end
