class CreateGlossaryMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :glossary_mappings do |t|
      t.integer :consultation_id
      t.integer :glossary_id

      t.timestamps
    end
  end
end
