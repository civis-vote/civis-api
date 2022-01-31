class AddIsInternationalCitiesToLocation < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :is_international_city, :boolean, default: false
  end
end
