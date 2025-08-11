class Question < ApplicationRecord
  acts_as_paranoid

  include CmAdmin::Question

  belongs_to :parent, class_name: "Question", optional: true
  belongs_to :response_round, optional: true
  has_many :sub_questions, class_name: 'Question', foreign_key: :parent_id

  enum question_type: { checkbox: 0, multiple_choice: 1, long_text: 2, dropdown: 3 }

  validates :question_text, presence: true

  accepts_nested_attributes_for :sub_questions, allow_destroy: true, reject_if: proc { |attributes| attributes['question_text'].blank? }

  def display_options?
    checkbox? || multiple_choice? || dropdown?
  end
end
