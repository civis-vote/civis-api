module Types
  module Objects
    module ConsultationResponse
      class OptionBreakdown < BaseObject
        graphql_name "OptionBreakdown"
        description "Selection count for a single option within a question"

        field :option_id,       Int,    "ID of the sub-question (option)", null: false
        field :option_text,     String, "Text of the option", null: false
        field :selection_count, Int,    "Number of responses that selected this option", null: false
        field :percentage,      Float,  "Percentage of total responses that selected this option", null: false
      end
    end
  end
end
