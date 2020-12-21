class AddReferencesResponseRoundToConsultationResponse < ActiveRecord::Migration[6.0]
  def change
  	add_reference :consultation_responses, :response_round, null: true, foreign_key: true
    ConsultationResponse.reset_column_information
  	ConsultationResponse.all.each do |consultation_response|
  		if consultation_response.respondent
  			consultation_response.update(response_round_id: consultation_response.respondent.response_round_id)
  		else
  			consultation_response.update(response_round_id: consultation_response.consultation.response_rounds.order(:created_at).last.id)
  		end
  	end
  end
end
