class AddIconNameToThemes < ActiveRecord::Migration[8.1]
  def change
    add_column :themes, :icon_name, :string, if_not_exists: true
  end
end
