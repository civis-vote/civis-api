class AddDeletedAtToConsultations < ActiveRecord::Migration[6.0]
  def change
    add_column :consultations, :deleted_at, :datetime
    add_index :consultations, :deleted_at
    add_column :consultation_responses, :deleted_at, :datetime
    add_index :consultation_responses, :deleted_at
    add_column :categories, :deleted_at, :datetime
    add_index :categories, :deleted_at
    add_column :ministries, :deleted_at, :datetime
    add_index :ministries, :deleted_at
    add_column :organisations, :deleted_at, :datetime
    add_index :organisations, :deleted_at
    add_column :questions, :deleted_at, :datetime
    add_index :questions, :deleted_at
  end
end