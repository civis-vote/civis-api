module Types
  module Objects
    class QuestionType < BaseObject
      graphql_name 'BaseQuestionType'
      field :id, Int, 'ID of the question', null: false
      field :is_optional, Boolean, nil, null: false
      field :position, Integer, nil, null: true
      field :question_type, String, nil, null: true
      field :question_text, String, nil, null: true
      field :hindi_question_text, String, nil, null: true
      field :odia_question_text, String, nil, null: true
      field :marathi_question_text, String, nil, null: true
      field :parent, Types::Objects::QuestionType, nil, null: true
      field :sub_questions, [Types::Objects::QuestionType], nil, null: true
      field :selected_options_limit, Integer, nil, null: true
      field :is_conditional_question, Boolean, null: true
      field :accept_voice_message, Boolean, null: true
      field :has_choice_priority, Boolean, null: true
      field :conditional_question, Types::Objects::QuestionType, null: true
      field :supports_other, Boolean, nil, null: false

      def hindi_question_text
        object.question_text_hindi if object.question_text_hindi.present?
      end

      def odia_question_text
        object.question_text_odia if object.question_text_odia.present?
      end

      def marathi_question_text
        object.question_text_marathi if object.question_text_marathi.present?
      end

      def is_conditional_question
        object.conditional_question?
      end
    end
  end
end
