class AddPointsToConsultationResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :consultation_responses, :points, :float, default: 0.0
  end
end
