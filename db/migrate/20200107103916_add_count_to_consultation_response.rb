class AddCountToConsultationResponse < ActiveRecord::Migration[6.0]
  def change
    add_column :consultation_responses, :up_vote_count, :integer, null: false, default: 0
    add_column :consultation_responses, :down_vote_count, :integer, null: false, default: 0
    ConsultationResponse.all.each &:refresh_consultation_response_up_vote_count
		ConsultationResponse.all.each &:refresh_consultation_response_down_vote_count
  end
end
