class CreateCtUserGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :ct_user_groups do |t|
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
