class AddActiveToOrganisation < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :active, :boolean, default: true
    add_column :users, :active, :boolean, default: true
  end
end