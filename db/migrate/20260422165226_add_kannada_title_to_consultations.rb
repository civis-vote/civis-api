class AddKannadaTitleToConsultations < ActiveRecord::Migration[7.1]
  def change
    add_column :consultations, :title_kannada, :string
  end
end
