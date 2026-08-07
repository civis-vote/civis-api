module Types
  module Objects
    module ConsultationResponse
      class QuestionSummary < BaseObject
        graphql_name "QuestionSummary"
        description "Aggregated response data for a single question"

        field :id,                   Int,      "ID of the question summary record", null: false
        field :question_id,          Int,      "ID of the question", null: false
        field :question_text,        String,   "Question text", null: false
        field :question_type,        String,   "Type of question (checkbox/multiple_choice/long_text/dropdown)", null: false
        field :is_optional,          Boolean,  "Whether the question is optional", null: false
        field :position,             Int,      "Display order", null: true
        field :total_responses,      Int,      "Number of responses that answered this question", null: false
        field :option_breakdown,     [Types::Objects::ConsultationResponse::OptionBreakdown],
              "Per-option selection counts (for choice-based questions)", null: true
        field :text_response_count,  Int,      "Number of text responses (for long_text questions)", null: true
        field :voice_response_count, Int,      "Number of voice responses (for questions accepting voice)", null: true
        field :other_option_count,   Int,      "Number of responses that used the 'Other' option", null: true

        def option_breakdown
          object.option_breakdowns
        end
      end
    end
  end
end
