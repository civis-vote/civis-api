class AddThemeToConsultations < ActiveRecord::Migration[7.1]
  def change
    add_reference :consultations, :theme, foreign_key: true
  end
end
