class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :name

      t.timestamps
    end
    category = ["Education", "Environment, Waste Management", "Healthcare, Women and Child Development, Sanitation, Accessibility", "Agriculture, Rural Development", "Telecom, Internet, Media", "Finance, Energy, Industry", "Urban Settlements", "Others"]
    category.each do |category_name|
    	Category.create!(name: category_name)
    end
  end
end
