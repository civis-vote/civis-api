class CreateCaseStudies < ActiveRecord::Migration[6.0]
  def change
    create_table :case_studies do |t|
      t.string :name
      t.string :ministry_name
      t.integer :no_of_citizens
      t.string :url
      t.integer :created_by_id

      t.timestamps
    end
  end
end
