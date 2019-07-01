class CreateConsultations < ActiveRecord::Migration[6.0]
  def change
    create_table :consultations do |t|
      t.string :title, null: false
      t.string :url
      t.datetime :response_deadline
      t.references :ministry, null: false, foreign_key: true
      t.integer :status, default: 0
      t.integer :created_by_id

      t.timestamps
    end
  end
end
