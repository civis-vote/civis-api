class AddIsApprovedToMinistries < ActiveRecord::Migration[6.0]
  def change
    add_column :ministries, :is_approved, :boolean, default: false
  end
end
