class AddUniqIndexToConsultationResponseVote < ActiveRecord::Migration[6.0]
  def change
  	add_index :consultation_response_votes, [:consultation_response_id, :user_id], unique: true, name: :consultation_response_id_and_user_id_index
  end
end
