class Question < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  include CmAdmin::Question

  belongs_to :parent, class_name: "Question", optional: true
  belongs_to :response_round, optional: true
  belongs_to :conditional_question, class_name: 'Question', optional: true

  has_many :sub_questions, -> { order(position: :asc) }, class_name: 'Question', foreign_key: :parent_id
  has_many :conditional_question_options, class_name: 'Question', foreign_key: :conditional_question_id

  enum question_type: { checkbox: 0, multiple_choice: 1, long_text: 2, dropdown: 3 }

  positioned on: %i[parent response_round]

  validates :question_text, presence: true
  validate :conditional_question_should_be_optional
  validate :validate_selected_options_limit_equal_or_less_than_options

  accepts_nested_attributes_for :sub_questions, allow_destroy: true, reject_if: proc { |attributes| attributes['question_text'].blank? }

  scope :main_questions, -> { where(parent_id: nil) }

  scope :search_filter, lambda { |search|
    return all if search.blank?

    where('question_text ILIKE ?', "%#{search}%")
  }

  scope :is_conditional_questions, lambda { |option|
    return all if option.blank?

    conditional_ids = ::Question.where.not(conditional_question_id: nil).select(:conditional_question_id)
    if option == 'true'
      where(id: conditional_ids)
    elsif option == 'false'
      where.not(id: conditional_ids)
    else
      none
    end
  }

  def display_options?
    checkbox? || multiple_choice? || dropdown?
  end

  def conditional_question?
    conditional_question_options.present?
  end

  private

  def conditional_question_should_be_optional
    return if conditional_question.blank? || conditional_question&.is_optional

    errors.add(:conditional_question, 'Conditional question should be optional')
  end

  def validate_selected_options_limit_equal_or_less_than_options
    remaining_options = sub_questions.reject(&:marked_for_destruction?)
    errors.add(:selected_options_limit, 'can not be greater than options') if remaining_options.size < selected_options_limit.to_i
  end
end
