class RemoveThemeFromDepartment < ActiveRecord::Migration[7.1]
  def change
    remove_reference :departments, :theme
  end
end
