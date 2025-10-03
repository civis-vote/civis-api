class ChangeTableNamesForMinisityCategory < ActiveRecord::Migration[7.1]
  def change
    rename_table :ministries, :departments
    rename_table :categories, :themes

    rename_column :consultations, :ministry_id, :department_id

    rename_column :departments, :category_id, :theme_id
    change_column :departments, :theme_id, :bigint
    add_index :departments, :theme_id
  end
end
