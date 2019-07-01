class AddPublishedAtToConsultations < ActiveRecord::Migration[6.0]
  def change
    add_column :consultations, :published_at, :datetime
  end
end
