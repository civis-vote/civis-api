class ResponseSummary < ApplicationRecord
  belongs_to :consultation

  has_many :question_summaries, class_name: 'ResponseQuestionSummary', dependent: :destroy
  has_many :option_breakdowns, through: :question_summaries

  accepts_nested_attributes_for :question_summaries, allow_destroy: true
end
