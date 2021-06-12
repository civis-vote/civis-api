class ChangeUserIdToConsultationRespons < ActiveRecord::Migration[6.0]
  def change
  	change_column :consultation_responses, :user_id, :bigint, foreign_key: true, null: true
  end
end
