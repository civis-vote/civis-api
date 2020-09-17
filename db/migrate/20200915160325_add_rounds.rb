class AddRounds < ActiveRecord::Migration[6.0]
  def change
  	add_column :response_rounds, :round, :integer
  	Consultation.all.each do |consultation|
			consultation.response_rounds.order(:created_at).each_with_index do |response_round, index|
				response_round.update(round: "#{index + 1}")
			end
		end
  end
end