class ChangeDefaultValueForShowSatisfaction < ActiveRecord::Migration[7.1]
  def change
    change_column_default :consultations, :show_satisfaction_rating, from: false, to: true
  end
end
