class CreateGlossaryMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :glossary_mappings do |t|
      t.string :consultation_id
      t.string :glossary_id

      t.timestamps
    end
  end
end
