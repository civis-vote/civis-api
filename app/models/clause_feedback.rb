class ClauseFeedback < ApplicationRecord
  has_paper_trail

  belongs_to :clause
  belongs_to :consultation_response

  has_rich_text :feedback_comment
  has_rich_text :feedback_reason

  delegate :consultation, to: :clause, allow_nil: true
end
