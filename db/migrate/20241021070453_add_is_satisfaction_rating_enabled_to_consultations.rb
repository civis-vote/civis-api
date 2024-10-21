class AddIsSatisfactionRatingEnabledToConsultations < ActiveRecord::Migration[7.1]
  def up
    add_column :consultations, :is_satisfaction_rating_optional, :boolean, default: false, null: false
  end

  def down
    remove_column :consultations, :is_satisfaction_rating_optional
  end
end