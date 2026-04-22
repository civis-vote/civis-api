class AddKannadaNameToDepartments < ActiveRecord::Migration[7.1]
  def change
    add_column :departments, :name_kannada, :string
  end
end
