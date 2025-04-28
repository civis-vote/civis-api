class AddMarathiTitleToConsultations < ActiveRecord::Migration[7.1]
  def change
    add_column :consultations, :title_marathi, :string
  end
end
