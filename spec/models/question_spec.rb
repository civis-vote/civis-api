require 'rails_helper'

RSpec.describe Question, type: :model do
  let(:consultation) { create(:consultation) }
  let(:response_round) { consultation.response_rounds.last }

  def create_question(attrs = {})
    response_round.questions.create!({
      question_text: "Question #{SecureRandom.hex(4)}", question_type: :multiple_choice, is_optional: true
    }.merge(attrs))
  end

  describe 'validations' do
    it 'needs a question text' do
      expect(Question.new(response_round:)).not_to be_valid
    end

    it 'rejects a conditional question pointing at a mandatory question' do
      mandatory = create_question(is_optional: false)

      expect do
        create_question(conditional_question: mandatory)
      end.to raise_error(ActiveRecord::RecordInvalid, /Conditional question should be optional/)
    end

    it 'caps selected_options_limit at the number of options' do
      question = create_question(sub_questions_attributes: [{ question_text: 'Yes' }])

      question.selected_options_limit = 3

      expect(question).not_to be_valid
    end
  end

  describe 'scopes' do
    it 'lists main questions without parents' do
      question = create_question
      create_question(parent: question)

      expect(response_round.questions.main_questions).to contain_exactly(question)
    end

    it 'searches by question text' do
      question = create_question(question_text: 'Do you support the policy?')

      expect(Question.search_filter('support')).to include(question)
    end
  end

  describe '#display_options?' do
    it 'is true for choice-based questions' do
      expect(create_question(question_type: :checkbox)).to be_display_options
      expect(create_question(question_type: :dropdown)).to be_display_options
    end

    it 'is false for long text questions' do
      expect(create_question(question_type: :long_text)).not_to be_display_options
    end
  end
end
