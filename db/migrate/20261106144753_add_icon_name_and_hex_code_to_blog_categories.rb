class AddIconNameAndHexCodeToBlogCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :blog_categories, :icon_name, :string
    add_column :blog_categories, :hex_code, :string
  end
end
