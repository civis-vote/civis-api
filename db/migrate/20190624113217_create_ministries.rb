class CreateMinistries < ActiveRecord::Migration[6.0]
  def change
    create_table :ministries do |t|
      t.string :name
      t.integer :category_id
      t.integer :level
      t.string :poc_email

      t.timestamps
    end
  end
end
