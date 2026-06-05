class AddWhatIsProposedToClauses < ActiveRecord::Migration[8.1]
  def change
    add_column :clauses, :what_is_being_proposed, :string
  end
end
