class ResponseRound < ApplicationRecord
  has_paper_trail

  include CmAdmin::ResponseRound

  belongs_to :consultation, optional: true

  has_many :questions
  has_many :respondents
  has_many :consultation_responses

  after_commit :add_response_round, on: :create

  def add_response_round
    round_count = consultation.response_rounds.count
    self.round_number = round_count
    save
  end
end
