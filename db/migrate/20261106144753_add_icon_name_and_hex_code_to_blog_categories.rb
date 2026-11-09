class AddIconNameAndHexCodeToBlogCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :blog_categories, :icon_name, :string, if_not_exists: true
    add_column :blog_categories, :hex_code, :string, if_not_exists: true
  end
end
