class AddReviewTypeToConsultation < ActiveRecord::Migration[6.0]
  def change
    add_column :consultations, :review_type, :integer, default: 0
  end
end
