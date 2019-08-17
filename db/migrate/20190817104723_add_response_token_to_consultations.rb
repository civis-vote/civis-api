class AddResponseTokenToConsultations < ActiveRecord::Migration[6.0]
  def change
    add_column :consultations, :response_token, :uuid
  end
end
