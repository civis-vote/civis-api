class CreateConsultations < ActiveRecord::Migration[6.0]
  def change
    create_table :consultations do |t|
      t.string :title
      t.string :url
      t.datetime :response_deadline
      t.references :ministry, null: false, foreign_key: true
      t.integer :status
      t.integer :created_by_id

      t.timestamps
    end
  end
end
