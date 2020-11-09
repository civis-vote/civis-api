class ResponseRound < ApplicationRecord
	belongs_to :consultation, optional: true
	has_many :questions
	has_many :respondents
	has_many :consultation_responses

	def add_response_round
		round_count = self.consultation.response_rounds.count
		self.round_number = round_count
		self.save
	end
end
