class AddDbIndexOnQuestionLocation < ActiveRecord::Migration[7.1]
  def change
    add_index :questions, :parent_id
    add_index :locations, :parent_id
    add_index :locations, :location_type
    add_index :consultation_responses, %i[response_status visibility]
  end
end
