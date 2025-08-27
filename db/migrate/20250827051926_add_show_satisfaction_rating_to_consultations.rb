class AddShowSatisfactionRatingToConsultations < ActiveRecord::Migration[7.1]
  def change
    add_column :consultations, :show_satisfaction_rating, :boolean, default: false
  end
end
