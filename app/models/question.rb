class Question < ApplicationRecord
  acts_as_paranoid

  include CmAdmin::Question

  belongs_to :parent, class_name: "Question", optional: true
  belongs_to :response_round, optional: true
  belongs_to :conditional_question, class_name: 'Question', optional: true
  belongs_to :conditional_question_option, class_name: 'Question', optional: true

  has_many :sub_questions, class_name: 'Question', foreign_key: :parent_id
  has_many :conditional_questions, class_name: 'Question', foreign_key: :conditional_question_option_id

  enum question_type: { checkbox: 0, multiple_choice: 1, long_text: 2, dropdown: 3 }

  validates :question_text, presence: true

  accepts_nested_attributes_for :sub_questions, allow_destroy: true, reject_if: proc { |attributes| attributes['question_text'].blank? }

  scope :search_filter, lambda { |search|
    return all if search.blank?

    where('question_text ILIKE ?', "%#{search}%")
  }

  def display_options?
    checkbox? || multiple_choice? || dropdown?
  end
end
