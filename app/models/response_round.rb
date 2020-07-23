class ResponseRound < ApplicationRecord
	belongs_to :consultation, optional: true
	has_many :questions
	has_many :respondents
end
