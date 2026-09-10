class AddCtaLabelToConsultations < ActiveRecord::Migration[8.1]
  def change
    add_column :consultations, :cta_label, :string
  end
end
