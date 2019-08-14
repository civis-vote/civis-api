class AddIsFeaturedToConsultations < ActiveRecord::Migration[6.0]
  def change
    add_column :consultations, :is_featured, :boolean, default: false
  end
end
