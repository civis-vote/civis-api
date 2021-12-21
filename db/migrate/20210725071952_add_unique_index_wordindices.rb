class AddUniqueIndexWordindices < ActiveRecord::Migration[6.0]
  def change
    add_index :wordindices, :word, unique: true
  end
end