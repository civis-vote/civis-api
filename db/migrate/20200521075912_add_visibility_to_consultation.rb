class AddVisibilityToConsultation < ActiveRecord::Migration[6.0]
  def change
    add_column :consultations, :visibility, :integer, default: 0
  end
end
