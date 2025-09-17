class AddPositionToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :questions, :position, :integer
  end
end
