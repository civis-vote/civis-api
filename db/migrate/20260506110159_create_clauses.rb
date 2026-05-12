class CreateClauses < ActiveRecord::Migration[8.1]
  def change
    create_table :clauses do |t|
      t.string :clause_id, null: false
      t.string :clause_title, null: false
      t.string :stakeholder_impact
      t.string :keywords
      t.references :consultation, null: false, foreign_key: true
      t.references :clause_type, null: true, foreign_key: { to_table: :constants }

      t.timestamps
    end
  end
end
