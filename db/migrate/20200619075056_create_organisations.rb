class CreateOrganisations < ActiveRecord::Migration[6.0]
  def self.up
    create_table :organisations do |t|
      t.string :name
      t.text :logo_data
      t.integer :created_by_id
      t.integer :users_count, default: 0

      t.timestamps
    end
    add_reference :users, :organisation, foreign_key: true
  end

  def self.down
  	drop_table :organisations
  end
end
