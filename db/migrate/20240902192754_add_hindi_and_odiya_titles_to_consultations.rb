class AddHindiAndOdiyaTitlesToConsultations < ActiveRecord::Migration[7.1]
  def up
    add_column :consultations, :title_hindi, :string
    add_column :consultations, :title_odia, :string
  end

  def down
    remove_column :consultations, :title_hindi
    remove_column :consultations, :title_odia
  end
end
