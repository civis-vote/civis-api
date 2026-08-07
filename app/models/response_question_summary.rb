class ResponseQuestionSummary < ApplicationRecord
  belongs_to :response_summary

  has_many :option_breakdowns, class_name: 'ResponseOptionBreakdown', dependent: :destroy

  accepts_nested_attributes_for :option_breakdowns, allow_destroy: true
end
