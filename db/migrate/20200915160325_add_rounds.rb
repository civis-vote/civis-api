class AddRounds < ActiveRecord::Migration[6.0]
  def self.up
  	ResponseRound.reset_column_information
  	add_column :response_rounds, :round_number, :integer
  	Consultation.all.each do |consultation|
			consultation.response_rounds.order(:created_at).each_with_index do |response_round, index|
				response_round.update(round_number: "#{index + 1}")
			end
		end
  end
end