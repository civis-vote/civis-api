class RemoveThemeFromDepartment < ActiveRecord::Migration[7.1]
  def change
    remove_column :departments, :theme_id
  end
end
