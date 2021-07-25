class RemoveIndexWordindices < ActiveRecord::Migration[6.0]
  def change
    remove_index :profanities, name: "index_wordindices_on_word"
  end
end