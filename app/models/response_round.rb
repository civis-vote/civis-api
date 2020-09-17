class ResponseRound < ApplicationRecord
	belongs_to :consultation, optional: true
	has_many :questions
	has_many :respondents
	after_commit :add_response_round, on: :create

	def add_response_round
		round_count = self.consultation.response_rounds.count
		self.round = round_count
		self.save
	end
end
