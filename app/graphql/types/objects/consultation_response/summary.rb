module Types
  module Objects
    module ConsultationResponse
      class Summary < BaseObject
        graphql_name "ConsultationResponseSummary"
        description "Aggregated summary of all responses for a consultation (stored as jsonb, computed on expiry)"

        field :consultation_id,   Int,      "ID of the consultation", null: false
        field :total_responses,   Int,      "Total number of responses", null: false
        field :questions,         [Types::Objects::ConsultationResponse::QuestionSummary], "Per-question aggregated data", null: false
      end
    end
  end
end
